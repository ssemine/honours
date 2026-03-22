#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$SLURM_CONF"
source "$PHENO_CONF"

for n in $(seq 0.00 0.05 1.00); do
	sbatch \
		--account="$ACCOUNT_STRING" \
		--partition="$PARTITION" \
		--cpus-per-task="$CPUS" \
		--mem="$MEM_RUN_TBLUP" \
		--time="$TIME" \
		--output="$LOGS_TBLUP_DIR/%x_%j.out" \
		--error="$LOGS_TBLUP_DIR/%x_%j.err" \
		--job-name="oreml_${n}" \
		--wrap="/home/s4693165/honours/scripts/sh/pipeline/run.sh --n-pca 4 --trm-cutoff ${n}"
done
