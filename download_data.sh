#!/usr/bin/env bash
set -euo pipefail

runs=(SRR12647619 SRR12647620)
mkdir -p data/raw

echo "Downloading runs: ${runs[*]}"
for run in "${runs[@]}"; do
  report=$(curl -s "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${run}&result=read_run&fields=fastq_ftp")
  urls=$(echo "$report" | tail -n +2 | grep -o 'ftp[^[:space:]]*fastq\.gz')
  while IFS= read -r url; do
    [[ $url == ftp://* ]] || url="ftp://$url"
    wget -q -O "data/raw/$(basename "$url")" "$url"
  done <<< "$urls"
done
