#!/usr/bin/env bash
# Minimal staged 1BNA DNA smoke-test driver. Parameterize the system separately with DNA.bsc1/TIP3P.
# This is a template: assess box, restraints, and ionization for each user system.
set -euo pipefail

: "${ENGINE:?Set ENGINE to pmemd.cuda.}"
: "${TOP:?Set TOP to a DNA.bsc1/TIP3P topology.}"
: "${RST:?Set RST to the matching solvated restart.}"
: "${OUT_DIR:?Set OUT_DIR to a new writable result directory.}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$OUT_DIR"

run() {
  local name="$1" input="$2" coordinate="$3"
  "$ENGINE" -O -i "$input" -o "$OUT_DIR/$name.out" -p "$TOP" -c "$coordinate" -r "$OUT_DIR/$name.rst7" -x "$OUT_DIR/$name.nc" -inf "$OUT_DIR/$name.mdinfo"
  MDOUT="$OUT_DIR/$name.out" "$SCRIPT_DIR/check_md_log.sh"
}

for restraint in 10.0 5.0 2.0 1.0 0.5 0.0; do
  tag="min_${restraint//./p}"
  input="$OUT_DIR/$tag.in"
  if [ "$restraint" = 0.0 ]; then positional='ntr=0,'; else positional="ntr=1, restraint_wt=$restraint, restraintmask=':1-24',"; fi
  cat > "$input" <<EOF
Staged steepest-descent minimization
&cntrl
  imin=1, maxcyc=1000, ncyc=1000, ntb=1, ntpr=100, $positional
/
EOF
  previous="${last_rst:-$RST}"
  run "$tag" "$input" "$previous"
  last_rst="$OUT_DIR/$tag.rst7"
done

cat > "$OUT_DIR/nvt_50ps.in" <<'EOF'
50 ps NVT heating/equilibration
&cntrl
 imin=0, irest=0, ntx=1, nstlim=25000, dt=0.002, ntc=2, ntf=2,
 tempi=50.0, temp0=300.0, ntt=3, gamma_ln=1.0, ntb=1, ntpr=5000, ntwx=5000, ntwr=25000, ioutfm=1,
/
EOF
run nvt_50ps "$OUT_DIR/nvt_50ps.in" "$last_rst"; last_rst="$OUT_DIR/nvt_50ps.rst7"

for phase in restrained_npt_100ps unrestrained_npt_100ps; do
  if [ "$phase" = restrained_npt_100ps ]; then positional="ntr=1, restraint_wt=1.0, restraintmask=':1-24',"; else positional='ntr=0,'; fi
  cat > "$OUT_DIR/$phase.in" <<EOF
100 ps NPT equilibration
&cntrl
 imin=0, irest=1, ntx=5, nstlim=50000, dt=0.002, ntc=2, ntf=2,
 temp0=300.0, ntt=3, gamma_ln=1.0, ntb=2, ntp=1, barostat=2, pres0=1.0, taup=2.0,
 $positional ntpr=5000, ntwx=5000, ntwr=25000, ioutfm=1,
/
EOF
  run "$phase" "$OUT_DIR/$phase.in" "$last_rst"; last_rst="$OUT_DIR/$phase.rst7"
done

echo "PASS: nine staged smoke-test phases completed. Analyse only after checking structural metrics."
