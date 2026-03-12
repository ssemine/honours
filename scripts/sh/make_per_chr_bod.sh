#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

for n in {1..29}; do
	osca --befile "$GENE_EXP_FILTERED_AUTOSOME_AFC_DATA" --chr $n --make-bod --out "$GENE_EXP_DIR/chr${n}_$GENE_EXP_FILTERED_AUTOSOME_AFC_FILENAME"
done
