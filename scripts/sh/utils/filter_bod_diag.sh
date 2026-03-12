#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"



excl_iids="$GENE_EXP_DIR/outliers.list"
osca --befile "$GENE_EXP_FILTERED_AUTOSOME_AFC_DATA" --remove "$excl_iids" --make-bod --out "$GENE_EXP_FINAL_AFC_DATA"
