#!/bin/bash

source /home/s4693165/honours/config/paths.conf

for n in {1..4}; do
    echo "Running get_covar.sh for TRM $n ..."
    /home/s4693165/honours/scripts/sh/utils/get_pca.sh \
        --n-pca "$n" \
        --befile "$GENE_EXP_FILTERED_DATA" \
        --out-pca out_befile="$(dirname "$PCA_DATA")/$(basename "$PCA_DATA")_${n}"
done