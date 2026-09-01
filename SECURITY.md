# Security and sanitization

Please do not file issues containing credentials, private keys, access tokens, cloud endpoints, account identifiers, internal paths, full job logs, or proprietary Amber distributions.

Before publishing a derivative run, execute:

```bash
python3 scripts/scan_sensitive_content.py .
```

The scanner is a conservative warning tool, not a substitute for human review. Review all images and text before publishing.
