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

############################################
# Edit this
############################################

REF=Ref/rCRS.fasta

THREADS=${SLURM_CPUS_PER_TASK:-8}

############################################

mkdir -p sai
mkdir -p sam
mkdir -p bam

echo "======================================"
echo "Starting BWA alignment"
echo "Reference : ${REF}"
echo "Threads   : ${THREADS}"
echo "Started   : $(date)"
echo "======================================"

############################################
# Loop over all FASTQ files
############################################

for FASTQ in *.all_merged.gz
do

    [[ -e "$FASTQ" ]] || continue

    #SAMPLE=${FASTQ%.truncated.gz}
    SAMPLE=${SAMPLE%.all_merged.gz}

    echo
    echo "Processing ${SAMPLE}"

    ########################################
    # bwa aln
    ########################################

    bwa aln \
        -t ${THREADS} \
        -l 1024 \
        -n 0.01 \
        -o 2 \
        ${REF} \
        ${FASTQ} \
        > sai/${SAMPLE}.sai

    ########################################
    # bwa samse
    ########################################

    bwa samse \
        ${REF} \
        sai/${SAMPLE}.sai \
        ${FASTQ} \
        > sam/${SAMPLE}.sam

    ########################################
    # BAM
    ########################################

    samtools view \
        -@ ${THREADS} \
        -bS \
        sam/${SAMPLE}.sam \
    | samtools sort \
        -@ ${THREADS} \
        -o bam/${SAMPLE}.sorted.bam

    samtools index bam/${SAMPLE}.sorted.bam

    ########################################
    # Mapping statistics
    ########################################

    samtools flagstat \
        bam/${SAMPLE}.sorted.bam \
        > bam/${SAMPLE}.flagstat

    ########################################
    # Cleanup
    ########################################

    #rm sam/${SAMPLE}.sam
    #rm sai/${SAMPLE}.sai

done

echo
echo "======================================"
echo "Finished $(date)"
echo "======================================"
