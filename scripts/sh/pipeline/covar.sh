#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

for n in {1..4}; do
    echo "Running get_covar.sh for TRM $n ..."
    "$SH_UTILS_DIR/get_pca.sh" \
        --n-pca "$n" \
        --befile "$GENE_EXP_FILTERED_DATA" \
        --out-pca "$(dirname "$PCA_DATA")/$(basename "$PCA_DATA")_${n}"
done

"$SH_UTILS_DIR/get_covar.sh" \
    --pheno-file "$PHENO_DATA" \
    --iid-idx "$PHENO_IID_IDX" \
    --covar_idx "$CALVING_SUCCESS_IDX" \
    --out "$COVAR_DIR/calving_success.covar"