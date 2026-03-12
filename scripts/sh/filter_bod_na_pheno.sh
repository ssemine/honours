#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"
source "$BOD_CONF"
source "$OSCA_CONF"

module load "$OSCA_MODULE"

pheno_name="afc_"
pheno_idx=8
befile="$GENE_EXP_FILTERED_AUTOSOME_DATA"
excl_iids_filename="excluded_iids.list"
excl_iids="$GENE_EXP_DIR/$pheno_name$excl_iids_filename"
output_profile="$GENE_EXP_FILTERED_AUTOSOME_AFC_DATA"

gawk \
	-v phenoIdx="$pheno_idx" \
	-f "$AWK_SCRIPTS_DIR/filter_bod_na_pheno.awk" \
	"$PHENO_MAP_DATA" \
	"$PHENO_FILTERED_DATA" \
	> "$excl_iids"

osca --befile "$befile" --remove "$excl_iids" --make-bod --out "$output_profile"

