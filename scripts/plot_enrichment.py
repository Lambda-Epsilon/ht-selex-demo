import pandas as pd, matplotlib.pyplot as plt, sys, pathlib
inp, out = sys.argv[1], sys.argv[2]
df = pd.read_csv(inp, sep="\t", names=["seq", "cnt0", "enr"])
plt.figure()
plt.loglog(df.index + 1, df["enr"])
plt.xlabel("Sequence rank")
plt.ylabel("Enrichment (round / round0)")
plt.tight_layout()
pathlib.Path(out).parent.mkdir(parents=True, exist_ok=True)
plt.savefig(out, dpi=300)
