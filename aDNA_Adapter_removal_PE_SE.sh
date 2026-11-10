#!/bin/sh
#SBATCH -N 1
#SBATCH --ntasks-per-node=40 
#SBATCH --time=4-00:00:00 
#SBATCH --job-name=adapter-kuru 
#SBATCH --error=adapter.err 
#SBATCH --output=adapter.out
#SBATCH --partition=standard
#SBATCH --nodelist=cn[022]

set -euo pipefail

###############################
# Load AdapterRemoval
###############################
module purge
module load AdapterRemoval/2.3.3


THREADS=35

mkdir -p AdapterRemoval_out
mkdir -p AdapterRemoval_logs

echo "======================================"
echo "AdapterRemoval2 Ancient DNA Processing"
echo "Started : $(date)"
echo "Threads : ${THREADS}"
echo "======================================"

#########################################
# paired-end libraries
#########################################

for R1 in *_1.fastq.gz
do
    [[ -e "$R1" ]] || break

    SAMPLE=${R1%_1.fastq.gz}
    R2=${SAMPLE}_2.fastq.gz

    if [[ ! -f "$R2" ]]; then
        echo "Missing mate for ${R1}"
        continue
    fi

    echo
    echo "Processing paired-end sample: ${SAMPLE}"

    if [[ -f AdapterRemoval_out/${SAMPLE}.settings ]]; then
        echo "Already finished. Skipping."
        continue
    fi

    AdapterRemoval \
        --file1 "$R1" \
        --file2 "$R2" \
        --basename AdapterRemoval_out/${SAMPLE} \
        --threads ${THREADS} \
        --trimns \
        --trimqualities \
        --minquality 20 \
        --minlength 25 \
        --collapse \
        --gzip \
        > AdapterRemoval_logs/${SAMPLE}.log 2>&1

done

#########################################
# single-end libraries
#########################################

for SE in *.fastq.gz
do

    [[ "$SE" == *_1.fastq.gz ]] && continue
    [[ "$SE" == *_2.fastq.gz ]] && continue

    SAMPLE=${SE%.fastq.gz}

    echo
    echo "Processing single-end sample: ${SAMPLE}"

    if [[ -f AdapterRemoval_out/${SAMPLE}.settings ]]; then
        echo "Already finished. Skipping."
        continue
    fi

    AdapterRemoval \
        --file1 "$SE" \
        --basename AdapterRemoval_out/${SAMPLE} \
        --threads ${THREADS} \
        --trimns \
        --trimqualities \
        --minquality 20 \
        --minlength 25 \
        --gzip \
        > AdapterRemoval_logs/${SAMPLE}.log 2>&1

done

echo
echo "======================================"
echo "All samples completed."
echo "Finished : $(date)"
echo "======================================"
