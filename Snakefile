import yaml
configfile: "config.yaml"
ROUND = config["rounds"]
DATASETS = config["datasets"]
ADAPTER = config["adapter"]
THREADS = int(config["threads"])

rule all:
    input:
        expand("results/{ds}/enrichment/enrichment_R{r}.tsv", ds=DATASETS, r=ROUND[1:]),
        expand("results/{ds}/motifs/R{r}", ds=DATASETS, r=ROUND[1:]),
        expand("results/{ds}/plots/enrichment_R{r}.png", ds=DATASETS, r=ROUND[1:])

rule fastqc:
    input: "data/raw/{file}.fastq.gz"
    output: "results/{file}/qc/{file}_fastqc.zip"
    shell: "fastqc -q -o results/{wildcards.file}/qc {input}"

rule trim:
    input: "data/raw/{file}.fastq.gz"
    output: "results/{file}/trimmed/{file}.trimmed.fastq.gz"
    shell: "cutadapt -j {THREADS} -a {ADAPTER} -o {output} {input}"

rule count:
    input: "results/{file}/trimmed/{file}.trimmed.fastq.gz"
    output: "results/{file}/counts/{file}.tsv"
    script: "scripts/count_seqs.py"

rule enrichment:
    input:
        round0="results/{ds}/counts/{ds}_R0.tsv",
        other="results/{ds}/counts/{ds}_R{r}.tsv"
    output: "results/{ds}/enrichment/enrichment_R{r}.tsv"
    script: "scripts/calc_enrichment.py"

rule meme:
    input: "results/{ds}/enrichment/enrichment_R{r}.tsv"
    output: directory("results/{ds}/motifs/R{r}")
    shell: """
    awk '{print ">"NR"\\n"$1}' {input} | head -n 2000 > tmp.fa
    meme tmp.fa -oc {output} -dna -mod zoops -nmotifs 5 -minw 6 -maxw 12
    rm tmp.fa
    """

rule plot:
    input: "results/{ds}/enrichment/enrichment_R{r}.tsv"
    output: "results/{ds}/plots/enrichment_R{r}.png"
    script: "scripts/plot_enrichment.py"
