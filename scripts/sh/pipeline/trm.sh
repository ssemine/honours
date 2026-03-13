#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

# make_trm.sh -> get_covar.sh -> get_pca.sh -> run_oreml.sh

# tblup/trm/cuttrm
echo "Running make_trm.sh for all data ..."
"$SH_UTILS_DIR/make_trm.sh" \
        --befile "$GENE_EXP_FILTERED_DATA" \
        --trm-cutoff 1.00 \
        --out-trm "$TRM_DATA"

for chr in {1..29}; do
    echo "Running make_trm.sh for chromosome $chr ..."
    "$SH_UTILS_DIR/make_trm.sh" \
        --befile "$GENE_EXP_FILTERED_DATA" \
        --chr "$chr" \
        --trm-cutoff 1.00 \
        --out-trm "$TRM_DATA"
done