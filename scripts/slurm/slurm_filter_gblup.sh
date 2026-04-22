#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$SLURM_CONF"
initial_bfile="$GENOMIC_DATA"
auto_bfile="$GENOMIC_DATA"

pheno_map="$PHENO_MAP_DATA"
pheno_file="$PHENO_DATA"
excl_iids_not_shared="$EXCL_IIDS_FGBBLUP1"
shared_bfile="$GENOMIC_FILTER_BED_PHENO_DATA"
shared_pheno="$GBLUP_PHENO_FILTERED_DATA"
iid_pheno="$GBLUP_PHENO_IID_DATA"
no_na_bfile="$GENOMIC_FILTER_BED_NA_PHENO_DATA"
afc_900_bfile="$GENOMIC_FILTER_BED_900_PHENO_DATA"

mkdir -p "$LOGS_GBLUP_DIR"
mkdir -p "$PHENO_DIR/gblup"
mkdir -p "$GENOMIC_PREPROCESSED_DIR"

sbatch \
  --account="$ACCOUNT_STRING" \
  --partition="$PARTITION" \
  --cpus-per-task="2" \
  --mem="128G" \
  --time="$TIME" \
  --output="$LOGS_GBLUP_DIR/%x_%j.out" \
  --error="$LOGS_GBLUP_DIR/%x_%j.err" \
  --job-name="bed_assembly" \
  --wrap="/home/s4693165/honours/scripts/sh/pipeline/gblup/filter_gblup.sh \
--initial-bfile $initial_bfile \
--auto-bfile $auto_bfile \
--pheno-map $pheno_map \
--pheno $pheno_file \
--excl-iids-not-shared $excl_iids_not_shared \
--shared-bfile $shared_bfile \
--shared-pheno $shared_pheno \
--iid-pheno $iid_pheno \
--no-na-bfile $no_na_bfile \
--afc-900-bfile $afc_900_bfile"
