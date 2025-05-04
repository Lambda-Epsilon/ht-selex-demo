#!/usr/bin/env bash
set -euo pipefail
mkdir -p data/raw
runs=( $(grep '^[[:space:]]*-[[:space:]]*' config.yaml | sed 's/^[[:space:]]*-[[:space:]]*//') )
echo "Runs: ${runs[*]}"
for run in "${runs[@]}"; do
  report=$(curl -s "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${run}&result=read_run&fields=fastq_ftp")
  urls=$(echo "$report" | grep -o 'ftp[^[:space:];]*\.fastq\.gz')
  for url in $urls; do
    [[ $url == ftp://* ]] || url="ftp://$url"
    wget --show-progress -P data/raw "$url"
  done
done
ls -lh data/raw/*.fastq.gz || echo "No files found"
