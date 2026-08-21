# Security

## Model Boundary

Compression uses the active OpenCode conversation model. File prose may cross the configured model provider boundary, so the preflight rejects sensitive-looking filenames and private tool directories before the agent reads them.

## Local Script Behavior

The Python scripts:

- read only source and candidate paths supplied by the agent;
- reject unsupported, oversized, backup, and sensitive-looking files;
- validate protected Markdown before writing;
- create a non-overwriting sibling `.original.md` backup;
- atomically replace the source only after validation passes;
- never invoke a model, network client, shell, or external AI CLI;
- never execute source or candidate content.

Failed validation leaves source and backup unchanged. Existing backups cause a hard failure.

## Reporting

Report suspected vulnerabilities through the project's security issue process without attaching sensitive source files.
