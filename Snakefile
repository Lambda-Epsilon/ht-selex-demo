configfile: "config.yaml"

# Load configuration
ROUND    = config["rounds"]
DATASETS = config["datasets"]
ADAPTER  = config["adapter"]
THREADS  = int(config["threads"])

# Default target: enrichment, motifs, and plots for rounds > 0
rule all:
    input:
        expand("results/{ds}/enrichment/enrichment_R{r}.tsv", ds=DATASETS, r=ROUND[1:]),
        expand("results/{ds}/motifs/R{r}",             ds=DATASETS, r=ROUND[1:]),
        expand("results/{ds}/plots/enrichment_R{r}.png", ds=DATASETS, r=ROUND[1:])

rule fastqc:
    input:
        raw="data/raw/{ds}_R{r}.fastq.gz"
    output:
        zip="results/{ds}/qc/{ds}_R{r}_fastqc.zip"
    shell:
        """
        mkdir -p results/{wildcards.ds}/qc
        fastqc -q -o results/{wildcards.ds}/qc {input.raw}
        """

rule trim:
    input:
        raw="data/raw/{ds}_R{r}.fastq.gz"
    output:
        trimmed="results/{ds}/trimmed/{ds}_R{r}.trimmed.fastq.gz"
    threads: THREADS
    shell:
        """
        mkdir -p results/{wildcards.ds}/trimmed
        cutadapt -j {threads} -a {ADAPTER} -o {output.trimmed} {input.raw}
        """

rule count:
    input:
        trimmed="results/{ds}/trimmed/{ds}_R{r}.trimmed.fastq.gz"
    output:
        counts="results/{ds}/counts/{ds}_R{r}.tsv"
    shell:
        """
        mkdir -p results/{wildcards.ds}/counts
        python scripts/count_seqs.py {input.trimmed} {output.counts}
        """

rule enrichment:
    input:
        round0="results/{ds}/counts/{ds}_R0.tsv",
        current="results/{ds}/counts/{ds}_R{r}.tsv"
    output:
        "results/{ds}/enrichment/enrichment_R{r}.tsv"
    shell:
        """
        mkdir -p results/{wildcards.ds}/enrichment
        python scripts/calc_enrichment.py {input.round0} {input.current} {output}
        """

rule meme:
    input:
        "results/{ds}/enrichment/enrichment_R{r}.tsv"
    output:
        directory("results/{ds}/motifs/R{r}")
    log:
        "logs/meme_{ds}_R{r}.log"
    shell:
        "python scripts/run_meme.py {input} {output} {log}"


rule plot:
    input:
        "results/{ds}/enrichment/enrichment_R{r}.tsv"
    output:
        "results/{ds}/plots/enrichment_R{r}.png"
    threads: THREADS
    shell:
        """
        mkdir -p results/{wildcards.ds}/plots
        python scripts/plot_enrichment.py {input} {output}
        """
