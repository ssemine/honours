#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

for n in {1..29}; do
	gene_exp_data="$GENE_EXP_DIR/chr${n}_$GENE_EXP_FILTERED_AUTOSOME_AFC_FILENAME" # either filtered or not

	osca --befile "$gene_exp_data" --make-orm --orm-alg "$ORM_ALG_STANDARD" --out "$TBLUP_TRM_DIR/trm_afc_chr${n}_standard"
	osca --befile "$gene_exp_data" --make-orm --orm-alg "$ORM_ALG_CENTRED" --out "$TBLUP_TRM_DIR/trm_afc_chr${n}_centred"
	osca --befile "$gene_exp_data" --make-orm --orm-alg "$ORM_ALG_ITERATIVE" --out "$TBLUP_TRM_DIR/trm_afc_chr${n}_iterative"
done

