---
name: caveman-compress
description: Compress natural-language memory files into terse prose while preserving protected Markdown exactly. Use for /caveman-compress or requests to compress AGENTS.md, notes, todos, or preferences.
---

# Caveman Compress

Compress prose with the active OpenCode model. Python scripts only preflight, validate, back up, and atomically install the result; they never invoke another model or CLI.

## Workflow

1. Resolve the requested file to an absolute path. Reject missing arguments.
2. From this skill directory, run:

   ```bash
   python3 -m scripts check <absolute-source-path>
   ```

3. Read the source only after preflight passes.
4. Create a sibling candidate named `.<source-name>.caveman-candidate.md` with `apply_patch`.
5. Compress only natural-language prose according to the rules below.
6. Run:

   ```bash
   python3 -m scripts validate <absolute-source-path> <absolute-candidate-path>
   ```

7. If validation fails, fix only listed mismatches. Retry validation at most twice; never broadly recompress during correction.
8. After validation passes, run:

   ```bash
   python3 -m scripts apply <absolute-source-path> <absolute-candidate-path>
   ```

9. Delete the candidate after successful application. Report source and `<stem>.original.md` backup paths.
10. On any failure, leave source and existing backup untouched. Remove only the candidate created by this workflow.

## Remove

- Articles and filler
- Pleasantries and hedging
- Redundant wording
- Connective fluff

## Preserve Exactly

- Frontmatter and all Markdown headings
- Fenced and indented code blocks
- Inline code
- URLs and Markdown links
- File paths and commands
- Identifiers, technical terms, and proper nouns
- Dates, versions, and numeric values
- List hierarchy and table structure

Do not add an outer Markdown fence around the candidate.

## Style

- Use short synonyms.
- Fragments are acceptable.
- State actions directly.
- Merge only truly redundant prose.
- Keep one example when several prove the same point.

## Boundaries

- Accept `.md`, `.txt`, `.rst`, and extensionless natural-language files.
- Never modify code, config, environment, lock, shell, database, or markup files.
- Never compress `*.original.md`.
- Reject files over 500 KB.
- Reject paths likely to contain credentials, keys, secrets, or private tool state.
- If code versus prose is uncertain, preserve it.
