#!/usr/bin/env python3
import sys, os, subprocess

if len(sys.argv) != 4:
    print("Usage: run_meme.py <enrichment.tsv> <outdir> <logfile>")
    sys.exit(1)

tsv, outdir, log = sys.argv[1:]
os.makedirs(outdir, exist_ok=True)

fasta = os.path.join(outdir, "tmp.fa")
with open(tsv) as inf, open(fasta, "w") as outf:
    next(inf)  # skip header
    for i, line in enumerate(inf, 1):
        seq = line.split()[0]
        outf.write(f">{i}\n{seq}\n")
        if i >= 2000:
            break

if os.path.getsize(fasta) == 0:
    print(f"No sequences for MEME in {tsv}", file=sys.stderr)
    sys.exit(1)

with open(log, "w") as lf:
    subprocess.run([
        "meme", fasta,
        "-oc", outdir,
        "-dna", "-mod", "zoops",
        "-nmotifs", "5", "-minw", "6", "-maxw", "12"
    ], stdout=lf, stderr=lf, check=True)

os.remove(fasta)
