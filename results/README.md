# Derived validation evidence

These tables are deliberately small, derived summaries. They support the operational claim that a patched Amber 26 CUDA build performed short real-GPU molecular-dynamics smoke tests. They are not raw simulation data and must not be used for biological or force-field conclusions.

| System | Protocol | Primary observation | Scope |
|---|---|---|---|
| Amber reference DHFR | 500 ps NVT; 2 fs timestep | completed 250,000 steps; final-window mean temperature 299.698 K | official pre-parameterized regression input |
| 1BNA DNA | staged minimization + 50 ps NVT + 100 ps restrained NPT + 100 ps NPT; 2 fs timestep | 9/9 stages completed; no hard runtime/numerical failure tokens | DNA.bsc1/TIP3P short structural-health smoke |

The charts in `assets/` are generated from the TSV tables by `scripts/render_result_figures.py`.
