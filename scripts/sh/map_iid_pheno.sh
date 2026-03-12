#!/bin/bash

source /home/s4693165/honours/config/paths.conf

oii_file="$GENE_EXP_FILTERED_AUTOSOME_AFC_OII_DATA"
gawk \
	-f "$AWK_SCRIPTS_DIR/map_iid_pheno.awk" \
	"$PHENO_MAP_DATA" \
	"$oii_file" \
	"$PHENO_FILTERED_DATA" \
	> "$PHENO_IID_DATA"
