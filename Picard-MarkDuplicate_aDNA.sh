#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --time=4-00:00:00
#SBATCH --job-name=bwa-aln
#SBATCH --error=bwa.err
#SBATCH --output=bwa.out
#SBATCH --partition=gpu
#SBATCH --nodelist=gpu[004]


set -euo pipefail

THREADS=${SLURM_CPUS_PER_TASK:-16}

mkdir -p dedup

echo "Starting duplicate removal: $(date)"

for BAM in bam/*.sorted.bam
do
    SAMPLE=$(basename "$BAM" .sorted.bam)

    echo "Processing ${SAMPLE}"

    ############################################
    # Mark/remove duplicates
    ############################################

    samtools markdup \
        -r \
        -@ ${THREADS} \
        "$BAM" \
        - \
    | samtools view \
        -@ ${THREADS} \
        -b \
        -F 4 \
        -o "dedup/${SAMPLE}.dedup.bam"

    ############################################
    # Index
    ############################################

    samtools index \
        -@ ${THREADS} \
        "dedup/${SAMPLE}.dedup.bam"

    ############################################
    # QC
    ############################################

    samtools flagstat \
        "dedup/${SAMPLE}.dedup.bam" \
        > "dedup/${SAMPLE}.dedup.flagstat"

    samtools coverage \
        "dedup/${SAMPLE}.dedup.bam" \
        > "dedup/${SAMPLE}.coverage.txt"

done

echo "Finished: $(date)"
