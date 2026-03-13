#!/bin/bash

# exclude_sex_chr.sh -> filter_bod_pheno.sh -> filter_bod_na_pheno.sh -> map_iid_pheno.sh PHENOTYPE AND BOD PREP
# make_trm.sh -> get_covar.sh -> get_pca.sh -> run_oreml.sh

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

# Filters BOD for sex chromosomes
echo "Running exclude_sex_chr.sh ..."
/home/s4693165/honours/scripts/sh/utils/exclude_sex_chr.sh \
    --befile "$GENE_EXP_DATA" \
    --opi "$GENE_EXP_OPI_DATA" \
    --out-gene-list "$GENE_EXP_AUTO_GENE_LIST" \
    --out-bod "$GENE_EXP_AUTO_DATA"

# Filters BOD and phenotype files by excluding non-shared individuals
echo "Running filter_bod_pheno.sh ..."
/home/s4693165/honours/scripts/sh/utils/filter_bod_pheno.sh \
    --pheno-map "$PHENO_MAP_DATA" \
    --pheno-file "$PHENO_DATA" \
    --befile "$GENE_EXP_AUTO_DATA" \
    --excl-iids "$EXCL_IIDS_ONE" \
    --oii "$GENE_EXP_AUTO_OII_DATA" \
    --out-bod "$GENE_EXP_FILTER_BOD_PHENO_DATA" \
    --out-pheno "$PHENO_FILTERED_DATA"

# Filters BOD and phenotype files for NA values, specifically AFC
echo "Running filter_bod_na_pheno.sh ..."
/home/s4693165/honours/scripts/sh/utils/filter_bod_na_pheno.sh \
    --pheno-idx "$CALVING_SUCCESS_IDX" \
    --pheno-map "$PHENO_MAP" \
    --pheno-file "$PHENO_FILTERED_DATA" \
    --befile "$GENE_EXP_FILTER_BOD_PHENO_DATA" \
    --excl-iids "$EXCL_IIDS_TWO" \
    --out-bod "$GENE_EXP_TMP_FILTERED_DATA"

# Standardises BOD files
echo "Running std_bod.sh ..."
/home/s4693165/honours/scripts/sh/utils/std_bod.sh \
    --befile "$GENE_EXP_TMP_FILTERED_DATA" \
    --out-bod "$GENE_EXP_FILTERED_DATA"

# Creates a copy of the phenotype file with IIDs instead of barcodes
echo "Running map_iid_pheno.sh ..."
/home/s4693165/honours/scripts/sh/utils/map_iid_pheno.sh \
    --pheno-map "$PHENO_MAP" \
    --pheno-file "$PHENO_FILTERED_DATA" \
    --oii "$GENE_EXP_FILTERED_OII_DATA" \
    --out-pheno "$PHENO_IID_DATA" \