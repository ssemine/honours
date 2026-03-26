#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$SLURM_CONF"
source "$PHENO_CONF"

arg1="--use-covar-idx-file"
arg2="--covar-idx-file"
c_file="combo"
arg3="/home/s4693165/honours/scripts/slurm/$c_file"

arg4="--covars"
arg5="3 5"
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
		--wrap="/home/s4693165/honours/scripts/sh/pipeline/tblup/run_tblup.sh --n-pca 2 ${arg1} ${arg2} ${arg3} --trm-cutoff ${n}"
done
