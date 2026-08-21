#!/usr/bin/env python3
"""Validate and atomically install an agent-produced compressed file."""

import os
import re
import tempfile
from pathlib import Path

from .detect import should_compress
from .validate import ValidationResult, validate

MAX_FILE_SIZE = 500_000

SENSITIVE_BASENAME_REGEX = re.compile(
    r"(?ix)^("
    r"\.env(\..+)?"
    r"|\.netrc"
    r"|credentials(\..+)?"
    r"|secrets?(\..+)?"
    r"|passwords?(\..+)?"
    r"|id_(rsa|dsa|ecdsa|ed25519)(\.pub)?"
    r"|authorized_keys"
    r"|known_hosts"
    r"|.*\.(pem|key|p12|pfx|crt|cer|jks|keystore|asc|gpg)"
    r")$"
)
SENSITIVE_PATH_COMPONENTS = frozenset({".ssh", ".aws", ".gnupg", ".kube", ".docker"})
SENSITIVE_NAME_TOKENS = (
    "secret",
    "credential",
    "password",
    "passwd",
    "apikey",
    "accesskey",
    "token",
    "privatekey",
)


def is_sensitive_path(filepath: Path) -> bool:
    """Return whether a path is unsafe to send through the active model."""
    if SENSITIVE_BASENAME_REGEX.match(filepath.name):
        return True
    lowered_parts = {part.lower() for part in filepath.parts}
    if lowered_parts & SENSITIVE_PATH_COMPONENTS:
        return True
    normalized_name = re.sub(r"[_\-\s.]", "", filepath.name.lower())
    return any(token in normalized_name for token in SENSITIVE_NAME_TOKENS)


def backup_path_for(filepath: Path) -> Path:
    """Return the non-overwriting human-readable backup path."""
    return filepath.with_name(filepath.stem + ".original.md")


def preflight(filepath: Path) -> Path:
    """Validate a source before the agent reads or compresses it."""
    filepath = filepath.expanduser().resolve()
    if not filepath.exists():
        raise FileNotFoundError(f"File not found: {filepath}")
    if not filepath.is_file():
        raise ValueError(f"Not a file: {filepath}")
    if filepath.stat().st_size > MAX_FILE_SIZE:
        raise ValueError(f"File too large to compress safely (max 500KB): {filepath}")
    if is_sensitive_path(filepath):
        raise ValueError(
            f"Refusing to compress {filepath}: path looks sensitive "
            "(credentials, keys, secrets, or known private paths)."
        )
    if not should_compress(filepath):
        raise ValueError(f"File is not supported natural-language content: {filepath}")

    backup_path = backup_path_for(filepath)
    if backup_path.exists():
        raise FileExistsError(
            f"Backup already exists: {backup_path}. Remove or rename it before retrying."
        )
    return filepath


def validate_candidate(filepath: Path, candidate_path: Path) -> ValidationResult:
    """Validate a candidate without changing source, candidate, or backup."""
    filepath = preflight(filepath)
    candidate_path = candidate_path.expanduser().resolve()
    if not candidate_path.exists() or not candidate_path.is_file():
        raise FileNotFoundError(f"Candidate file not found: {candidate_path}")
    if candidate_path == filepath:
        raise ValueError("Candidate must be separate from the source file")
    if candidate_path.stat().st_size > MAX_FILE_SIZE:
        raise ValueError(f"Candidate is too large (max 500KB): {candidate_path}")
    return validate(filepath, candidate_path)


def commit_candidate(filepath: Path, candidate_path: Path) -> ValidationResult:
    """Validate, back up the source, then atomically install the candidate."""
    filepath = preflight(filepath)
    candidate_path = candidate_path.expanduser().resolve()
    result = validate_candidate(filepath, candidate_path)
    if not result.is_valid:
        return result

    original_text = filepath.read_text(encoding="utf-8")
    candidate_text = candidate_path.read_text(encoding="utf-8")
    backup_path = backup_path_for(filepath)
    backup_temp: Path | None = None
    replacement_temp: Path | None = None

    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=filepath.parent,
            prefix=f".{backup_path.name}.",
            suffix=".tmp",
            delete=False,
        ) as handle:
            handle.write(original_text)
            handle.flush()
            os.fsync(handle.fileno())
            backup_temp = Path(handle.name)

        # Hard-link creation is atomic and refuses to overwrite an existing backup.
        os.link(backup_temp, backup_path)

        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=filepath.parent,
            prefix=f".{filepath.name}.",
            suffix=".tmp",
            delete=False,
        ) as handle:
            handle.write(candidate_text)
            handle.flush()
            os.fsync(handle.fileno())
            replacement_temp = Path(handle.name)

        os.replace(replacement_temp, filepath)
        replacement_temp = None
        return result
    finally:
        if backup_temp is not None:
            backup_temp.unlink(missing_ok=True)
        if replacement_temp is not None:
            replacement_temp.unlink(missing_ok=True)
