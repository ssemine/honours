#!/bin/bash

# filter_bod_pheno.sh
# 
# Filters both the BOD .oii and the phenoptype files
# Usage: ./filter_bod_pheno.sh

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

excl_iids="$GENE_EXP_DIR/excluded_iids.list"

gawk \
	-v out_pheno="$PHENO_FILTERED_DATA" \
	-v out_missing="$excl_iids" \
	-f "$AWK_SCRIPTS_DIR/filter_bod_pheno.awk" \
	"$GENE_EXP_OII_DATA" \
	"$PHENO_MAP_DATA" \
	"$PHENO_DATA"

osca --befile "$GENE_EXP_DATA" --remove "$excl_iids" --make-bod --out "$GENE_EXP_FILTERED_DATA"
