#!/usr/bin/env bash
# Runs a 500 ps NVT smoke test using an officially distributed, pre-parameterized DHFR input.
# Obtain the input legally from your licensed Amber distribution; do not commit it here.
set -euo pipefail

: "${ENGINE:?Set ENGINE to pmemd.cuda.}"
: "${TOP:?Set TOP to the official DHFR topology.}"
: "${RST:?Set RST to the official DHFR restart.}"
: "${OUT_DIR:?Set OUT_DIR to a new writable result directory.}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$OUT_DIR"

cat > "$OUT_DIR/dhfr_500ps_nvt.in" <<'EOF'
500 ps NVT PMEMD CUDA smoke test
&cntrl
  imin=0, irest=1, ntx=5,
  nstlim=250000, dt=0.002,
  ntc=2, ntf=2,
  tempi=300.0, temp0=300.0,
  ntt=3, gamma_ln=1.0,
  ntb=1, ntp=0,
  ntpr=5000, ntwx=5000, ntwr=25000,
  ioutfm=1,
/
EOF

"$ENGINE" -O -i "$OUT_DIR/dhfr_500ps_nvt.in" -o "$OUT_DIR/dhfr_500ps_nvt.out" \
  -p "$TOP" -c "$RST" -r "$OUT_DIR/dhfr_500ps_nvt.rst7" -x "$OUT_DIR/dhfr_500ps_nvt.nc" -inf "$OUT_DIR/dhfr_500ps_nvt.mdinfo"
MDOUT="$OUT_DIR/dhfr_500ps_nvt.out" "$SCRIPT_DIR/check_md_log.sh"
test -s "$OUT_DIR/dhfr_500ps_nvt.rst7" && test -s "$OUT_DIR/dhfr_500ps_nvt.nc"
