#!/bin/bash

source /home/s4693165/honours/config/paths.conf

# exclude_sex_chr.sh -> filter_bod_pheno.sh -> filter_bod_na_pheno.sh -> map_iid_pheno.sh PHENOTYPE AND BOD PRE PREP
# make_trm.sh -> (filter_trm_outliers.sh) -> get_covar.sh -> get_pca.sh -> run_oreml.sh

mkdir -p "$GENE_EXP_PREPROCESSED_DIR"
mkdir -p "$GENE_EXP_FINAL_DIR"

# Initial BOD and phenotype filtering
./filter.sh

# Initial TRM assembly
#./trm.sh --intermediate --befile "$GENE_EXP_FILTER_BOD_900_PHENO_DATA" --trm-cutoff 1.00 --out-trm "$INTERMEDIATE_DIR/trm_900"
osca \
		--befile "$GENE_EXP_FILTER_BOD_900_PHENO_DATA" \
		--make-orm \
		--orm-cutoff 1.00 \
		--out "$INTERMEDIATE_DIR/trm_900"


# Outlier filtering
./filter_trm_outliers.sh \
    --befile "$GENE_EXP_FILTER_BOD_900_PHENO_DATA" \
    --trm "$INTERMEDIATE_DIR/trm_900" \
    --out-bod "$GENE_EXP_FINAL_DIR/final"

# Final TRM assembly
./trm.sh --befile "$GENE_EXP_FINAL_DIR/final" --trm-cutoff 1.00 --out-trm "$TBLUP_TRM_DIR/final_trm"