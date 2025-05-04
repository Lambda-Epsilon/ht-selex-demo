#!/usr/bin/env bash
set -euo pipefail
mkdir -p data/raw
accessions=(DRA009383 DRA009384)
for acc in "${accessions[@]}"; do
    prefetch "${acc}"
    fasterq-dump --threads 8 --split-files "${acc}" -O data/raw
    pigz -p 8 data/raw/"${acc}"*.fastq
done
