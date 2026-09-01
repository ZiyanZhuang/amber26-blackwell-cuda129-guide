# Publication sanitization policy

The repository contains only material safe to make public:

- generic scripts parameterized through environment variables;
- toolchain and GPU-family information needed to reproduce the build;
- small, derived summary tables and regenerated figures;
- input-independent acceptance criteria.

It intentionally excludes raw trajectories, restart files, topology files, job logs, provider/container identifiers, hostnames, IP addresses, account names and IDs, mount paths, SSH settings, credentials, tokens, and private source archives.

Run the scanner before every push:

```bash
python scripts/scan_sensitive_content.py .
```

The scanner is a guardrail, not a substitute for review. Inspect `git diff --cached` and `git status --ignored` before publishing.
