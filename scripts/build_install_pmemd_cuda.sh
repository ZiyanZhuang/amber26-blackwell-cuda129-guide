#!/usr/bin/env bash
# Build after configure_cuda129_sm120.sh. Source, build, and prefix stay user-controlled.
set -euo pipefail

: "${BUILD_DIR:?Set BUILD_DIR to the configured CMake build directory.}"
: "${PREFIX:?Set PREFIX to the desired installation directory.}"
JOBS="${JOBS:-8}"

cmake --build "$BUILD_DIR" --parallel "$JOBS"
cmake --install "$BUILD_DIR"

ENGINE="${ENGINE:-}"
if [ -z "$ENGINE" ]; then
  for candidate in "$PREFIX/bin/pmemd.cuda_SPFP" "$PREFIX/bin/pmemd.cuda"; do
    if [ -x "$candidate" ]; then ENGINE="$candidate"; break; fi
  done
fi
test -n "$ENGINE" && test -x "$ENGINE"
echo "Installed engine: $ENGINE"
"$ENGINE" -h > "$BUILD_DIR/pmemd_cuda_help.txt" 2>&1 || true
sed -n '1,20p' "$BUILD_DIR/pmemd_cuda_help.txt"
