#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

log2_transform=true
qc=true
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
        --log2-transform)
            log2_transform=true
            shift 1
            ;;
        --qc)
            qc=true
            shift 1
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
initial_befile="$GENE_EXP_FILTER_BOD_900_PHENO_DATA"
qc_bod="$GENE_EXP_PREPROCESSED_DIR/qc_befile_${trm_cutoff}"
std_bod="$GENE_EXP_PREPROCESSED_DIR/std_befile_${trm_cutoff}"
sd_min=0.02
missing_ratio_probe=0.05

echo "Start bod_qc.sh"
"$SH_PIPE_DIR/bod_qc.sh" \
    --befile "$initial_befile" \
    --qc \
    --sd-min "$sd_min" \
    --missing-ratio-probe "$missing_ratio_probe" \
    --log2-transform \
    --out-bod "$qc_bod"
echo "Finish bod_qc.sh"

"$SH_UTILS_DIR/std_bod.sh" \
    --befile "$qc_bod" \
    --out-bod "$std_bod"

osca \
    --befile "$std_bod" \
    --orm-cutoff "$trm_cutoff" \
    --make-orm \
    --out "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}_tmp"

osca \
	--orm "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}_tmp" \
    --orm-cutoff "$trm_cutoff" \
	--make-orm \
	--out "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}"

cp "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}.orm.id" "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}.list"
osca \
    --befile "$GENE_EXP_STD_DATA" \
    --keep "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}.list" \
    --make-bod \
    --out "$GENE_EXP_FINAL_DIR/final_${trm_cutoff}_tmp"
rm "$INTERMEDIATE_DIR/trm_900_${trm_cutoff}.list"

# Outlier filtering

"$SH_PIPE_DIR/filter_trm_outliers.sh" \
    --befile "$GENE_EXP_FINAL_DIR/final_${trm_cutoff}_tmp" \
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
    --trm "$TBLUP_TRM_DIR/final_trm_${trm_cutoff}" \
    --out-pca "$pca_data" \
    --n-pca "$n_pca"

"$SH_UTILS_DIR/run_oreml.sh" \
        --trm "$TBLUP_TRM_DIR/final_trm_${trm_cutoff}" \
        --out "$RESULTS_DIR/tblup_final_${trm_cutoff}" \
        --pheno "$oreml_pheno_data"

for ((pca=1; pca<=n_pca; pca++)); do
    pca_oreml="${pca_data}_${pca}"
    gawk \
        -f "$AWK_SCRIPTS_DIR/get_oreml_pca.awk" \
        -v n="$pca" \
        "$pca_data.eigenvec" \
        > "$pca_oreml.qcovar"
    "$SH_UTILS_DIR/run_oreml.sh" \
        --trm "$TBLUP_TRM_DIR/final_trm_${trm_cutoff}" \
        --qcovar-file "$pca_oreml.qcovar" \
        --out "$RESULTS_DIR/tblup_final_${trm_cutoff}_pca_${pca}" \
        --pheno "$oreml_pheno_data" 
done