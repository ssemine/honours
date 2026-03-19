#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$SLURM_CONF"

args=""

sbatch \
	--account="$ACCOUNT_STRING" \
	--partition="$PARTITION" \
	--cpus-per-task="$CPUS" \
	--mem="$MEM_MAKE_TRM" \
	--time="$TIME" \
	--output="$LOGS_TBLUP_DIR/%x_%j.out" \
	--error="$LOGS_TBLUP_DIR/%x_%j.err" \
	--job-name="bod_assembly" \
	--wrap="/home/s4693165/honours/scripts/sh/pipeline/filter.sh"
