#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"
autosomal_genes="$GENE_EXP_DIR/autosomal_genes.list"
gawk \
	-f "$AWK_SCRIPTS_DIR/exclude_sex_chr.awk" \
	"$GENE_EXP_FILTERED_OPI_DATA" \
	> "$autosomal_genes"
osca --befile "$GENE_EXP_FILTERED_DATA" --genes "$autosomal_genes" --make-bod --out "$GENE_EXP_DIR/autosomal_$GENE_EXP_FILTERED_FILENAME"


