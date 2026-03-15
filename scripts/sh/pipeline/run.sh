#!/bin/bash

source /home/s4693165/honours/config/paths.conf

# exclude_sex_chr.sh -> filter_bod_pheno.sh -> filter_bod_na_pheno.sh -> map_iid_pheno.sh PHENOTYPE AND BOD PRE PREP
# make_trm.sh -> (filter_trm_outliers.sh) -> get_covar.sh -> get_pca.sh -> run_oreml.sh

mkdir -p "$GENE_EXP_PREPROCSESSED_DIR"
mkdir -p "$GENE_EXP_FINAL_DIR"

# Initial BOD and phenotype filtering
./filter.sh

# Initial TRM assembly
./trm.sh --intermediate --befile "$GENE_EXP_FILTERED_DATA" --trm-cutoff 1.00

# Outlier filtering
./filter_trm_outliers.sh

# Final TRM assembly
./trm.sh --befile "$GENE_EXP_FINAL_DATA" --trm-cutoff 1.00