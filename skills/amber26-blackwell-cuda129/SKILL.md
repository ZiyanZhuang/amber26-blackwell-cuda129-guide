---
name: amber26-blackwell-cuda129
description: Build, verify, and smoke-test Amber 26 PMEMD CUDA for Blackwell GPUs with CUDA 12.9, without exposing site-specific infrastructure.
---

# Amber 26 Blackwell CUDA 12.9

Use this skill to prepare a licensed Amber 26 source tree for a CUDA 12.9 Blackwell worker, or to audit an existing `pmemd.cuda` build. It is deliberately operational: compilation alone is never acceptance.

## Boundaries

- Require a legally obtained Amber source distribution; never redistribute it, its test cases, topology files, or patches that violate its licence.
- Keep source, build, installation, job, and results directories outside version control and pass them with environment variables.
- Never record hostnames, addresses, account identifiers, mount paths, SSH configuration, secrets, or raw trajectories in a public repository.

## Workflow

1. **Probe before changing anything.** Record `nvidia-smi` model/driver, `nvcc --version`, free space, writable installation location, and the exact Amber source version. Confirm that the intended worker really owns the GPU.
2. **Create a separate build and prefix.** Set `AMBER_SRC`, `BUILD_DIR`, `PREFIX`, and `CUDA_HOME`. Run `scripts/configure_cuda129_sm120.sh`. For CUDA 12.9 Blackwell, request `CMAKE_CUDA_ARCHITECTURES=120`.
3. **Compile and install.** Run `scripts/build_install_pmemd_cuda.sh`. Retain build output until a real GPU job passes.
4. **Preflight the installed binary.** Set `ENGINE=$PREFIX/bin/pmemd.cuda` and run `scripts/preflight_blackwell_pmemd.sh`. A missing `cuobjdump` is not a pass; it increases the importance of the GPU canary.
5. **Run a real protein canary.** Use the licensed official, pre-parameterized DHFR input with `scripts/run_official_dhfr_500ps_smoke.sh`. Check the output using `scripts/check_md_log.sh` and verify non-empty restart and NetCDF output.
6. **Run a nucleic-acid canary.** After independent DNA.bsc1/TIP3P parameterization, use `scripts/run_1bna_dna_bsc1_staged_smoke.sh` as a staged template. Inspect RMSD, RMSF, canonical base-pair hydrogen bonds, and helical descriptors with cpptraj/Curves+-style tools.
7. **Classify the result honestly.** Passing the gates means the executable ran the short tested cases. It does not certify equilibration, a force field, or a production model.

## Failure handling

`CUDA_ERROR`, `FATAL`, NaN/Inf, SHAKE errors, `REPEATED LINMIN FAILURE`, VDW overflow, and extreme gradients are hard failures. Preserve the first failing log. Then diagnose in order: worker/runtime identity, dynamic libraries and architecture, input/topology-restart pairing, minimization/restraints, and only finally production-length simulation.

See [validation gates](references/validation-gates.md) for the acceptance contract.
