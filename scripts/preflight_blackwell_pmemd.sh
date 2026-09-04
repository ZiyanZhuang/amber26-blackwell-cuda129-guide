#!/usr/bin/env bash
# Read-only compatibility checks. They do not replace a real MD canary.
set -euo pipefail

: "${ENGINE:?Set ENGINE to the installed pmemd.cuda executable.}"
test -x "$ENGINE"

echo '== GPU =='
nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
echo '== CUDA compiler =='
nvcc --version || true
echo '== CUDA libraries resolved by PMEMD =='
ldd "$ENGINE" | grep -E 'libcuda|libcudart|libnvrtc' || true
echo '== Architecture check =='
if command -v cuobjdump >/dev/null 2>&1; then
  arch_dump="${ARCH_DUMP:-${TMPDIR:-/tmp}/pmemd_cuda_architecture.txt}"
  cuobjdump --list-elf "$ENGINE" > "$arch_dump"
  if grep -q 'sm_120' "$arch_dump"; then
    echo 'PASS: sm_120 code object detected'
  else
    echo "WARN: sm_120 was not found by cuobjdump (full output: $arch_dump); require the real-GPU canary before accepting this build."
  fi
else
  echo 'WARN: cuobjdump unavailable; require the real-GPU canary before accepting this build.'
fi
