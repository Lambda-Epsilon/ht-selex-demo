import pandas as pd, sys, pathlib
r0, rn, out = sys.argv[1], sys.argv[2], sys.argv[3]
df0 = pd.read_csv(r0, sep="\t", names=["seq", "cnt0"])
dfn = pd.read_csv(rn, sep="\t", names=["seq", "cnt"])
df = dfn.merge(df0, on="seq", how="left").fillna(0)
df["enrichment"] = (df["cnt"] + 1) / (df["cnt0"] + 1)
pathlib.Path(out).parent.mkdir(parents=True, exist_ok=True)
df.sort_values("enrichment", ascending=False).to_csv(out, sep="\t", index=False, header=False)
