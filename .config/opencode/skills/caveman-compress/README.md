# caveman-compress

Compress natural-language memory files into terse prose while preserving protected Markdown. The active OpenCode model performs compression; local Python scripts enforce safety and atomic installation.

## Usage

```text
/caveman-compress AGENTS.md
```

Result:

```text
AGENTS.md          # compressed
AGENTS.original.md # human-readable backup
```

## Guarantees

- Source remains unchanged until validation passes.
- Existing backups are never overwritten.
- Headings, frontmatter, code blocks, inline code, URLs, paths, tables, and numbers are validated.
- Files over 500 KB and sensitive-looking paths are rejected.
- No nested model, external AI SDK, or subprocess-based AI client is used.

## Local Safety Commands

Run from the skill directory:

```bash
python3 -m scripts check /absolute/path/AGENTS.md
python3 -m scripts validate /absolute/path/AGENTS.md /absolute/path/.AGENTS.md.caveman-candidate.md
python3 -m scripts apply /absolute/path/AGENTS.md /absolute/path/.AGENTS.md.caveman-candidate.md
```

The OpenCode command creates and corrects the candidate before invoking `apply`.

## Supported Files

- `.md`, `.txt`, `.rst`
- Extensionless natural-language files

Code, configuration, environment, lock, backup, and sensitive-looking files are rejected.
