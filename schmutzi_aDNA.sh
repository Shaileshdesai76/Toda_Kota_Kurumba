#!/bin/bash

set -euo pipefail

THREADS=12
REF="Ref/rCRS.fasta"
FREQDIR="schmutzi/share/schmutzi/alleleFreqMT/197/freqs/"
OUTDIR="contDeam"

mkdir -p "$OUTDIR"

for BAM in dedup/*.dedup_MD.bam
do
    BASE=$(basename "$BAM" ".dedup_MD.bam")

    echo "======================================="
    echo "Processing: $BASE"
    echo "======================================="
    TMPBAM="dedup/${BASE}.tmp.bam"

    # Regenerate MD tags
    MDBAM="dedup/${BASE}.dedup_MD.bam"
    samtools calmd -b "$BAM" "$REF" > "$TMPBAM" &&
    samtools index "$TMPBAM" &&
    mv "$TMPBAM" "$BAM" &&
    mv "${TMPBAM}.bai" "${BAM}.bai"

    PREFIX="${OUTDIR}/${BASE}_MT_MD"

    # Initial contamination estimate
    schmutzi/src/contDeam.pl \
        --library double \
        --out "$PREFIX" \
        --uselength \
        --ref "$REF" \
        "$MDBAM"

    # Full Schmutzi
    schmutzi/src/schmutzi.pl \
        --ref "$REF" \
        --t "$THREADS" \
        "$PREFIX" \
        "$FREQDIR" \
        "$MDBAM"

    # Consensus FASTA (Q20)
    schmutzi/src/log2fasta \
        -q 20 \
        "${PREFIX}_final_endo.log" \
        > "${OUTDIR}/${BASE}_q20.fasta"

    echo "Finished $BASE"
    echo
done

echo "All samples completed successfully."
