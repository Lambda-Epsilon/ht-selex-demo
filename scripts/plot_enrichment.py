#!/usr/bin/env python3
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

def parse_args():
    p = argparse.ArgumentParser(description="Plot HT-SELEX enrichment")
    p.add_argument("tsv", help="Input enrichment TSV")
    p.add_argument("out", help="Output PNG file")
    return p.parse_args()

def main():
    args = parse_args()

    # Load data
    df = pd.read_csv(
        args.tsv, sep="\t", header=None,
        names=["seq", "count_curr", "count0", "enrichment"]
    )
    # Ensure numeric
    df["enrichment"] = pd.to_numeric(df["enrichment"], errors="coerce")
    df = df.dropna(subset=["enrichment"])

    # Compute rank (1-based)
    ranks = np.arange(1, len(df) + 1)

    # Plot
    plt.figure(figsize=(6,4))
    plt.loglog(ranks, df["enrichment"], linestyle="-", marker="")
    plt.xlabel("Sequence Rank")
    plt.ylabel("Enrichment Ratio")
    plt.title(f"Enrichment: {os.path.basename(args.tsv)}")
    plt.tight_layout()
    plt.savefig(args.out)
    plt.close()

if __name__ == "__main__":
    main()
