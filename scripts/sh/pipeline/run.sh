#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"


while [[ $# -gt 0 ]]; do
    case "$1" in
        --n-pca)
            n_pca="$2"
            shift 2
            ;;
        --trm-cutoff)
            trm_cutoff="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

mkdir -p "$GENE_EXP_PREPROCESSED_DIR"
mkdir -p "$GENE_EXP_FINAL_DIR"

oreml_pheno_data="$RESULTS_DIR/oreml_pheno_data_${trm_cutoff}.phen"
pca_data="$COVAR_DIR/pca_${trm_cutoff}"
excl_iids="$GENE_EXP_PREPROCESSED_DIR/excl_iids_trm_${trm_cutoff}.list"

osca \
		--befile "$GENE_EXP_STD_DATA" \
		--make-orm \
		--orm-cutoff "$trm_cutoff" \
		--out "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}"


# Outlier filtering

"$SH_PIPE_DIR/filter_trm_outliers.sh" \
    --befile "$GENE_EXP_STD_DATA" \
    --trm "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}" \
    --out-bod "$GENE_EXP_FINAL_DIR/final_${trm_cutoff}" \
    --excl-iids "$excl_iids"


# Final TRM assembly
"$SH_PIPE_DIR/trm.sh" \
    --befile "$GENE_EXP_FINAL_DIR/final_${trm_cutoff}" \
    --trm-cutoff "$trm_cutoff" \
    --out-trm "$TBLUP_TRM_DIR/final_trm_${trm_cutoff}"

"$SH_UTILS_DIR/get_oreml_pheno.sh" \
    --oii "$GENE_EXP_FINAL_DIR/final_${trm_cutoff}.oii" \
    --pheno-iid "$PHENO_IID_DATA" \
    --out-pheno "$oreml_pheno_data"

"$SH_UTILS_DIR/get_pca.sh" \
    --befile "$GENE_EXP_FINAL_DIR/final_${trm_cutoff}" \
    --trm "$TBLUP_TRM_DIR/final_trm_${trm_cutoff}" \
    --out-pca "$pca_data" \
    --n-pca "$n_pca"

for ((pca=1; pca<=n_pca; pca++)); do
    "$SH_UTILS_DIR/run_oreml.sh" \
        --trm "$TBLUP_TRM_DIR/final_trm_${trm_cutoff}" \
        --qcovar-file "$pca_data"_${pca}".eigenvec" \
        --out "$RESULTS_DIR/tblup_final_${trm_cutoff}_pca_${pca}" \
        --pheno "$oreml_pheno_data" 
done