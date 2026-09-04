# Amber 26 PMEMD CUDA on RTX 5060 with WSL2

This note records a sanitized local validation of the repository’s CUDA 12.9 / `sm_120` route on an NVIDIA GeForce RTX 5060. It is an engineering deployment record, not an Amber support statement or a scientific validation of any production model.

## Tested shape

| Item | Observed configuration |
|---|---|
| Windows integration | WSL2 with Ubuntu 24.04 |
| GPU | NVIDIA GeForce RTX 5060, compute capability 12.0 (`sm_120`), 8-GiB-class VRAM |
| CUDA | Toolkit 12.9 in WSL2; the Windows NVIDIA driver supplies the WSL GPU interface |
| Build tools | CMake, Ninja, GCC/GFortran, FFTW, NetCDF, BLAS/LAPACK, flex and bison |
| Amber target | Amber 26 PMEMD CUDA, `PMEMD_ONLY=TRUE` |
| Build parallelism | `-j8` on a 15-GiB WSL memory limit |

NVIDIA’s [CUDA GPU list](https://developer.nvidia.com/cuda/gpus) identifies compute capability 12.0 for the RTX 5060 family. For WSL2, follow the [official CUDA on WSL guide](https://docs.nvidia.com/cuda/wsl-user-guide/index.html): install the Windows display driver on Windows and the CUDA toolkit in WSL2; do not install a separate Linux NVIDIA kernel driver inside WSL2.

## Build route

Amber 26’s legacy CMake CUDA check treats CUDA 12.9 as outside its tested upper bound. The safe local workaround is:

1. Preserve the original source tree and its checksum.
2. Build from an independent copy.
3. In that copy only, widen the CUDA version check from `<12.9` to `<13.0`.
4. Restrict the CUDA 12.9 architecture flags to `compute_120` / `sm_120`.
5. Configure, build the complete configured PMEMD dependency closure, install, and inspect the installed binaries.

This is an experimental compatibility patch for the local CUDA 12.9 route. It must not be described as an official Amber 26 compatibility declaration.

The effective configuration used for this record was equivalent to:

```text
CUDA=TRUE
CUDA_TOOLKIT_ROOT_DIR=<WSL CUDA 12.9 toolkit>
CUDA_NVCC_EXECUTABLE=<WSL CUDA 12.9 toolkit>/bin/nvcc
CMAKE_CUDA_ARCHITECTURES=120
PMEMD_ONLY=TRUE
BUILD_PYTHON=FALSE
MPI=FALSE
INSTALL_TESTS=FALSE
BUILD_PERL=FALSE
BUILD_GUI=FALSE
DOWNLOAD_MINICONDA=FALSE
CHECK_UPDATES=FALSE
```

Use a WSL-native build directory and prefix. Building directly on a Windows-mounted filesystem is possible but slower and more sensitive to filesystem behavior. Keep one CUDA route, build cache, and install prefix together; do not mix a CUDA 12.9 tree with another toolkit or architecture route.

## Acceptance results

The validation ladder passed for this local installation:

| Gate | Result |
|---|---|
| Static build/install | `BUILD_PASS`: SPFP, DPFP, and the generic `pmemd.cuda` entry point installed |
| Dynamic libraries | `ldd` reported no `not found` entries |
| Device code | `cuobjdump --list-elf` showed `sm_120` code |
| Real GPU canary | `ENGINE_PASS`: official A-RNA GBSA4 short run reached `NSTEP=10` on the RTX 5060 |
| Output integrity | `TRAJECTORY_PASS`: non-empty mdout, mdinfo, restart, and 10-frame NetCDF output |
| Throughput | Official 4096-water workload reached `NSTEP=1000`; SPFP 214.8 ns/day, DPFP 13.9 ns/day |

The throughput values are from one short run without trajectory output. See [results/rtx5060_4096wat_throughput.tsv](../results/rtx5060_4096wat_throughput.tsv) for the compact, non-sensitive summary. They should be used for a rough local comparison, not as a promise for all driver versions, power limits, cooling profiles, or WSL configurations.

## Corrections that mattered

- The target is `sm_120`, not an older Blackwell architecture name and not `sm_121`; the RTX 5060 reports compute capability 12.0.
- CUDA 12.9 requires an isolated source copy because the legacy Amber CMake version guard rejects the boundary version.
- The repository log checker must match reported SHAKE/LINMIN failures, not the ordinary `SHAKE:` section header that appears in healthy output.
- A PMEMD-only prefix is not a complete AmberTools or `cpptraj` analysis stack. Do not claim trajectory-analysis coverage unless those tools are built and tested separately.
- Compilation and a zero exit code are insufficient. Require GPU identity, endpoint `NSTEP`, finite values, hard-error scan, and non-empty output artifacts.

## Scope boundary

This record establishes `BUILD_PASS`, `ENGINE_PASS`, and `TRAJECTORY_PASS` for the tested short cases. `SCIENTIFIC_VALIDATION` is intentionally **not claimed**: production-quality validation requires the user’s actual system, force field, parameterization, convergence checks, repeated runs, and domain-specific analysis.

No source archive, Amber binary, licensed test input, topology, restart, trajectory, raw log, username, hostname, local drive path, account identifier, credential, or private mount is stored in this repository.
