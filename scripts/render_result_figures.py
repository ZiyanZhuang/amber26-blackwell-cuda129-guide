#!/usr/bin/env python3
"""Regenerate public validation figures from compact, derived TSV summaries."""
from __future__ import annotations

import csv
from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results"
ASSETS = ROOT / "assets"
ASSETS.mkdir(exist_ok=True)
mpl.rcParams.update({"font.family": "DejaVu Sans", "svg.fonttype": "none", "pdf.fonttype": 42, "font.size": 9, "axes.spines.top": False, "axes.spines.right": False})

def read_tsv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))

def save(fig: plt.Figure, stem: str) -> None:
    for suffix, kwargs in (("png", {"dpi": 300}), ("svg", {}), ("pdf", {})):
        fig.savefig(ASSETS / f"{stem}.{suffix}", bbox_inches="tight", **kwargs)

def dhfr() -> None:
    rows = read_tsv(RESULTS / "dhfr_500ps_last20_temperature_K.tsv")
    sample = np.asarray([float(row["sample_index"]) for row in rows])
    temp = np.asarray([float(row["temperature_K"]) for row in rows])
    fig, (ax, table_ax) = plt.subplots(1, 2, figsize=(8.8, 3.4), gridspec_kw={"width_ratios": [1.45, 1]})
    ax.plot(sample, temp, color="#2563a9", marker="o", ms=3.2, lw=1.4)
    ax.axhline(temp.mean(), color="#d97706", lw=1.0, ls="--", label=f"mean = {temp.mean():.3f} K")
    ax.set(xlabel="Last reported sample index", ylabel="Temperature (K)", ylim=(292, 308), xlim=(0.5, 20.5), title="A  Official DHFR: final 20 reported temperatures")
    ax.legend(loc="lower right", fontsize=8)
    table_ax.axis("off")
    table_ax.set_title("B  GPU smoke-test receipt", loc="left", fontweight="bold")
    cells = [["Protocol", "500 ps NVT; 2 fs"], ["Completion", "250,000 steps"], ["Energy check", "4.50e-08 relative max"], ["Hard-error checks", "0 hits"], ["Interpretation", "Operational smoke test"]]
    table = table_ax.table(cellText=cells, colLabels=["Check", "Observed"], cellLoc="left", colLoc="left", loc="center", colWidths=[0.47, 0.66])
    table.auto_set_font_size(False); table.set_fontsize(8); table.scale(1, 1.55)
    for (row, col), cell in table.get_celld().items():
        cell.set_edgecolor("#d1d5db")
        if row == 0:
            cell.set_facecolor("#e8f0fa"); cell.set_text_props(weight="bold")
    fig.suptitle("Amber 26 PMEMD CUDA: protein reference-system validation", y=1.03, fontweight="bold")
    fig.tight_layout(); save(fig, "dhfr_500ps_gpu_smoke"); plt.close(fig)

def dna() -> None:
    rows = {row["metric"]: row for row in read_tsv(RESULTS / "dna_1bna_100ps_summary.tsv")}
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(8.8, 3.4), gridspec_kw={"width_ratios": [1.1, 1.25]})
    rmsd_names = ["Heavy atom", "Backbone"]
    rmsd_values = [float(rows["heavy_atom_rmsd_mean"]["value"]), float(rows["backbone_rmsd_mean"]["value"])]
    bars = ax1.bar(rmsd_names, rmsd_values, color=["#5b8db8", "#94b6d2"], width=0.62)
    ax1.set(ylabel="Mean RMSD (angstrom)", ylim=(0, 1.7), title="A  100 ps unrestrained NPT")
    for bar, value in zip(bars, rmsd_values):
        ax1.text(bar.get_x() + bar.get_width() / 2, value + 0.05, f"{value:.3f}", ha="center", va="bottom")
    labels = ["Stages passed", "Mean H-bonds", "Frames with >=2 H-bonds", "Mean rise", "Mean twist"]
    values = ["9 / 9", f"{float(rows['hydrogen_bonds_mean']['value']):.3f}", f"{100 * float(rows['frame_fraction_hbonds_at_least_2']['value']):.1f}%", f"{float(rows['basepair_step_rise_mean']['value']):.3f} A", f"{float(rows['basepair_step_twist_mean']['value']):.3f} deg"]
    ax2.axis("off")
    ax2.set_title("B  DNA structural-health receipt", loc="left", fontweight="bold")
    table = ax2.table(cellText=list(zip(labels, values)), colLabels=["Metric", "Observed"], cellLoc="left", colLoc="left", loc="center", colWidths=[0.60, 0.42])
    table.auto_set_font_size(False); table.set_fontsize(8); table.scale(1, 1.55)
    for (row, col), cell in table.get_celld().items():
        cell.set_edgecolor("#d1d5db")
        if row == 0:
            cell.set_facecolor("#e8f0fa"); cell.set_text_props(weight="bold")
    fig.suptitle("Amber 26 PMEMD CUDA: 1BNA DNA.bsc1 staged smoke test", y=1.03, fontweight="bold")
    fig.tight_layout(); save(fig, "dna_1bna_250ps_gpu_smoke"); plt.close(fig)

if __name__ == "__main__":
    dhfr(); dna()
