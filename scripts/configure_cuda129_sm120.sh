#!/usr/bin/env bash
# Configure an Amber source tree for one CUDA 12.9 / Blackwell build.
# Confirm the exact Amber release options against its official installation guide.
set -euo pipefail

: "${AMBER_SRC:?Set AMBER_SRC to an official Amber source directory.}"
: "${BUILD_DIR:?Set BUILD_DIR to an empty build directory.}"
: "${PREFIX:?Set PREFIX to a writable installation directory.}"
: "${CUDA_HOME:?Set CUDA_HOME to the CUDA 12.9 toolkit root.}"

test -d "$AMBER_SRC"
test -x "$CUDA_HOME/bin/nvcc"
mkdir -p "$BUILD_DIR" "$PREFIX"

cmake -S "$AMBER_SRC" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCUDA=TRUE \
  -DCMAKE_CUDA_COMPILER="$CUDA_HOME/bin/nvcc" \
  -DCMAKE_CUDA_ARCHITECTURES=120 \
  -DBUILD_PYTHON=FALSE
