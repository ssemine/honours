#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$SLURM_CONF"

for n in 0.01 0.025 0.05 0.075 0.1 0.25 0.5 0.75 1.00; do
	sbatch \
		--account="$ACCOUNT_STRING" \
		--partition="$PARTITION" \
		--cpus-per-task="$CPUS" \
		--mem="$MEM_RUN_TBLUP" \
		--time="$TIME" \
		--output="$LOGS_TBLUP_DIR/%x_%j.out" \
		--error="$LOGS_TBLUP_DIR/%x_%j.err" \
		--job-name="oreml" \
		--wrap="/home/s4693165/honours/scripts/sh/pipeline/run.sh --n-pca 4 --trm-cutoff ${n}"
done
