#!/usr/bin/env bash
# Fail closed on MD error signatures; retain the original log for diagnosis.
set -euo pipefail

: "${MDOUT:?Set MDOUT to the PMEMD output log to inspect.}"
test -s "$MDOUT"

hard_pattern='CUDA[_ ]ERROR|FATAL|(^|[^[:alnum:]_])(NaN|Inf)([^[:alnum:]_]|$)|SHAKE[^[:alnum:]]+(failed|failure|error)|REPEATED LINMIN FAILURE|LINMIN[^[:alnum:]]+(failed|failure|error)|VDW[^[:alnum:]]+overflow|extreme gradient|segmentation fault|abort'
if grep -Eqi "$hard_pattern" "$MDOUT"; then
  echo "FAIL: hard numerical or CUDA error signature in $MDOUT" >&2
  exit 1
fi
if ! grep -Eqi 'Total wall time|5\.  TIMINGS|\bNSTEP\b' "$MDOUT"; then
  echo "FAIL: no recognizable PMEMD progress/completion marker in $MDOUT" >&2
  exit 1
fi
echo "PASS: no configured hard-failure signatures in $MDOUT"
