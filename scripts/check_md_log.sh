#!/usr/bin/env bash
# Fail closed on MD error signatures; retain the original log for diagnosis.
set -euo pipefail

: "${MDOUT:?Set MDOUT to the PMEMD output log to inspect.}"
test -s "$MDOUT"

if grep -Eqi 'CUDA[_ ]ERROR|FATAL|\b(NaN|Inf)\b|SHAKE|REPEATED LINMIN FAILURE|VDW.*overflow|extreme gradient' "$MDOUT"; then
  echo "FAIL: hard numerical or CUDA error signature in $MDOUT" >&2
  exit 1
fi
if ! grep -Eqi 'Total wall time|5\.  TIMINGS|\bNSTEP\b' "$MDOUT"; then
  echo "FAIL: no recognizable PMEMD progress/completion marker in $MDOUT" >&2
  exit 1
fi
echo "PASS: no configured hard-failure signatures in $MDOUT"
