import gzip, sys, collections, pathlib
inp, out = sys.argv[1], sys.argv[2]
counter = collections.Counter()
with gzip.open(inp, "rt") as fh:
    for i, line in enumerate(fh):
        if i % 4 == 1:
            counter[line.strip()] += 1
pathlib.Path(out).parent.mkdir(parents=True, exist_ok=True)
with open(out, "w") as oh:
    for seq, cnt in counter.most_common():
        oh.write(f"{seq}\t{cnt}\n")
