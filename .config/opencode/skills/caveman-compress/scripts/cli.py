#!/usr/bin/env python3
"""Local safety CLI for OpenCode-native Caveman compression."""

import argparse
from pathlib import Path

from .compress import commit_candidate, preflight, validate_candidate


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="python -m scripts")
    subparsers = parser.add_subparsers(dest="command", required=True)

    check = subparsers.add_parser("check", help="check whether a source is safe to compress")
    check.add_argument("source", type=Path)

    validate = subparsers.add_parser("validate", help="validate a candidate without writing")
    validate.add_argument("source", type=Path)
    validate.add_argument("candidate", type=Path)

    apply = subparsers.add_parser("apply", help="validate and atomically install a candidate")
    apply.add_argument("source", type=Path)
    apply.add_argument("candidate", type=Path)
    return parser


def print_result(result) -> None:
    if result.is_valid:
        print("Validation passed")
        return
    print("Validation failed:")
    for error in result.errors:
        print(f"- {error}")


def main() -> None:
    args = build_parser().parse_args()
    try:
        if args.command == "check":
            source = preflight(args.source)
            print(f"Preflight passed: {source}")
            return

        if args.command == "validate":
            result = validate_candidate(args.source, args.candidate)
            print_result(result)
            raise SystemExit(0 if result.is_valid else 2)

        result = commit_candidate(args.source, args.candidate)
        print_result(result)
        if not result.is_valid:
            raise SystemExit(2)
        print(f"Compressed: {args.source.expanduser().resolve()}")
    except (FileNotFoundError, FileExistsError, ValueError, OSError) as error:
        print(f"ERROR: {error}")
        raise SystemExit(1) from error


if __name__ == "__main__":
    main()
