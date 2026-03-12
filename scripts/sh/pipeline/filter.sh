#!/bin/bash

# exclude_sex_chr.sh -> filter_bod_pheno.sh -> filter_bod_na_pheno.sh -> map_iid_pheno.sh PHENOTYPE AND BOD PREP
# make_trm.sh -> get_covar.sh -> get_pca.sh -> run_oreml.sh

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

pheno_prefix="afc_"

echo "Running exclude_sex_chr.sh ..."
../utils/exclude_sex_chr.sh \
    --befile "$GENE_EXP_DATA" \
    --opi "$GENE_EXP_OPI_DATA" \
    --out-gene-list "$GENE_EXP_AUTO_GENE_LIST" \
    --out-bod "$GENE_EXP_AUTO_DATA"

echo "Running filter_bod_pheno.sh ..."
../utils/filter_bod_pheno.sh \
    --pheno-map "$PHENO_MAP" \
    --pheno-file "$PHENO_DATA" \
    --befile "$GENE_EXP_AUTO_DATA" \
    --excl-iids "$EXCL_IIDS_ONE" \
    --oii "$GENE_EXP_AUTO_OII_DATA" \
    --out-bod "$GENE_EXP_FILTER_BOD_PHENO_DATA" \
    --out-pheno "$PHENO_FILTERED_DATA"

echo "Running filter_bod_na_pheno.sh ..."
../utils/filter_bod_na_pheno.sh \
    --pheno-idx "$CALVING_SUCCESS_IDX" \
    --pheno-map "$PHENO_MAP" \
    --pheno-file "$PHENO_FILTERED_DATA" \
    --befile "$GENE_EXP_FILTER_BOD_PHENO_DATA" \
    --excl-iids "$EXCL_IIDS_TWO" \
    --out-bod "$GENE_EXP_FILTERED_DATA"

echo "Running map_iid_pheno.sh ..."
../map_iid_pheno.sh \
    --pheno-map "$PHENO_MAP" \
    --pheno-file "$PHENO_FILTERED_DATA" \
    --oii "$GENE_EXP_FILTERED_OII_DATA" \
    --out-pheno "$PHENO_IID_DATA" \