#!/bin/sh
#SBATCH -N 1
#SBATCH --ntasks-per-node=40
#SBATCH --time=4-00:00:00
#SBATCH --job-name=admixture1
#SBATCH --error=admixture1.err
#SBATCH --output=admixture1.out
#SBATCH --partition=gpu
#SBATCH --nodelist=gpu[009]

# Activate conda environment (if needed)
# conda activate your_fastp_env

ulimit -n 65536

BED="$(realpath Adm_pop_file_pruned.bed)"
mkdir -p logs_K1_10 results_K1_10

export BED

run_admixture() {
    K="$1"
    REP="$2"
    SEED=$((K * 1000 + REP))

    DIR="$(pwd)/results_K1_10/K${K}_rep${REP}"
    mkdir -p "$DIR"

    LOG="$(pwd)/logs_K1_10/log_K${K}_rep${REP}.out"

    cd "$DIR" || exit 1

    admixture -s "$SEED" -j8 --cv "$BED" "$K" > "$LOG" 2>&1
}

export -f run_admixture

for K in {1..10}; do
    for REP in {1..10}; do
        echo "$K $REP"
    done
done | parallel -j 4 --colsep ' ' run_admixture {1} {2}

grep -h 'CV' logs_K1_10/log_K*_rep*.out