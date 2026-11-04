#!/bin/sh
#SBATCH -N 1
#SBATCH --ntasks-per-node=40
#SBATCH --time=4-00:00:00
#SBATCH --job-name=admixture
#SBATCH --error=admixture.err
#SBATCH --output=admixture.out
#SBATCH --partition=standard
#SBATCH --nodelist=cn[024]

conda activate popgenSDESAI

## this is for supervise admixture 
# Increase file handle limit

ulimit -n 65536

admixture -j8 --cv=10 Adm_pop_file_pruned.bed 10 \
    --supervised 2>&1 | tee logK10.out


# Extract the CV error
grep -h "CV error" admixture.log