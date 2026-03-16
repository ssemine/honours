#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

# Filters BOD for sex chromosomes CHECKED
echo "Running exclude_sex_chr.sh ..."
"$SH_UTILS_DIR/exclude_sex_chr.sh" \
    --befile "$GENE_EXP_DATA" \
    --opi "$GENE_EXP_OPI_DATA" \
    --out-gene-list "$GENE_EXP_AUTO_GENE_LIST" \
    --out-bod "$GENE_EXP_AUTO_DATA"

# Filters BOD and phenotype files by excluding non-shared individuals CHECKED
echo "Running filter_bod_pheno.sh ..."
"$SH_UTILS_DIR/filter_bod_pheno.sh" \
    --pheno-map "$PHENO_MAP_DATA" \
    --pheno-file "$PHENO_DATA" \
    --befile "$GENE_EXP_AUTO_DATA" \
    --excl-iids "$EXCL_IIDS_BOD_PHENO" \
    --oii "$GENE_EXP_AUTO_OII_DATA" \
    --out-bod "$GENE_EXP_FILTER_BOD_PHENO_DATA" \
    --out-pheno "$PHENO_FILTERED_DATA"

# Filters BOD and phenotype files for NA values, specifically AFC CHECKED
"$SH_UTILS_DIR/barcode_to_iid.sh" \
    --pheno-file "$PHENO_FILTERED_DATA" \
    --pheno-map "$PHENO_MAP_DATA" \
    --out "$PHENO_IID_DATA"

# CHECK FOR NA

"$SH_UTILS_DIR/filter_iid_na.sh" \
    --befile "$GENE_EXP_FILTER_BOD_PHENO_DATA" \
    --out-bod "$GENE_EXP_FILTER_BOD_NA_PHENO_DATA"

"$SH_UTILS_DIR/filter_pheno_900.sh" \
    --befile "$GENE_EXP_FILTER_BOD_PHENO_DATA" \
    --out-bod "$GENE_EXP_FILTER_BOD_900_PHENO_DATA"

# Standardises BOD files CHECKED
echo "Running std_bod.sh ..."
"$SH_UTILS_DIR/std_bod.sh" \
    --befile "$GENE_EXP_FILTER_BOD_900_PHENO_DATA" \
    --out-bod "$GENE_EXP_STD_DATA"
