# Amber CUDA acceptance contract

Accept a PMEMD CUDA build only when all of the following are recorded for the target worker: GPU and toolkit identity; resolved dynamic CUDA libraries; an architecture inspection when available; a real GPU start; a completed reference-system trajectory/restart; and a clean scan for CUDA, NaN/Inf, SHAKE, LINMIN, VDW-overflow, and extreme-gradient failures.

The exact warning/failure distinction is defined in the repository-level [validation-gates document](../../../docs/validation-gates.md).
