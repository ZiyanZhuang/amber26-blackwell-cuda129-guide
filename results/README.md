# Derived validation evidence

These tables are deliberately small, derived summaries. They support the operational claim that a patched Amber 26 CUDA build performed short real-GPU molecular-dynamics smoke tests. They are not raw simulation data and must not be used for biological or force-field conclusions.

| System | Protocol | Primary observation | Scope |
|---|---|---|---|
| Amber reference DHFR | 500 ps NVT; 2 fs timestep | completed 250,000 steps; final-window mean temperature 299.698 K | official pre-parameterized regression input |
| 1BNA DNA | staged minimization + 50 ps NVT + 100 ps restrained NPT + 100 ps NPT; 2 fs timestep | 9/9 stages completed; no hard runtime/numerical failure tokens | DNA.bsc1/TIP3P short structural-health smoke |
| RTX 5060 4096-water | 1,000 steps; 1 fs timestep; no trajectory output | SPFP 214.8 ns/day; DPFP 13.9 ns/day; both reached the endpoint with exit code 0 | One local WSL2 throughput run; see `rtx5060_4096wat_throughput.tsv` |

The charts in `assets/` are generated from the TSV tables by `scripts/render_result_figures.py`.

Throughput values are PMEMD-reported rates for a short official 4096-water reference workload. They are comparative engineering measurements, not a universal RTX 5060 performance guarantee. The benchmark deliberately avoids trajectory output so that the result primarily reflects engine throughput rather than storage/I/O speed.
