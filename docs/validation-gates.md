# Validation gates

This project treats a successful compilation as necessary but insufficient. A PMEMD CUDA installation is called *usable* only after it passes the following gates on the target GPU worker.

| Gate | Required evidence | Failure outcome |
|---|---|---|
| Runtime identity | GPU model, driver, CUDA toolkit, and `pmemd.cuda` executable are recorded | Stop: the build may be running on a different worker or toolkit |
| Binary compatibility | `ldd` resolves CUDA libraries from the selected runtime; the CUDA object contains `sm_120` code when inspected | Stop: rebuild for the actual architecture/runtime |
| Real GPU initialization | A short PMEMD CUDA job produces a normal startup and progress output | Stop: CUDA/runtime error |
| Numerical health | No CUDA fatal error, NaN/Inf, SHAKE failure, repeated LINMIN failure, or VDW-overflow indication | Stop: inspect the model and/or installation |
| Checkpoint integrity | Expected restart/trajectory/log artifacts exist and are non-empty | Stop: do not interpret a partial run as a passing run |
| Physics-aware smoke test | A documented, pre-parameterized reference system completes with conservative acceptance checks | Report only as a smoke test; it does not validate a production model |

## Non-negotiable error policy

Treat the following as hard failures even if a process exits with code zero: `NaN`, `Inf`, `CUDA_ERROR`, `FATAL`, a reported SHAKE failure, `REPEATED LINMIN FAILURE`, a reported LINMIN failure, VDW overflow, segmentation fault, abort, or extreme gradients. A normal `SHAKE:` section header is not an error by itself. Preserve the original log before retrying, then change one variable at a time.

## What these gates do and do not establish

Passing gates establishes that the tested executable can initialize and integrate the tested short systems on the tested worker. It does **not** establish ensemble convergence, force-field accuracy, free-energy accuracy, reproducibility across hardware, or suitability of a user-specific parameterization.
