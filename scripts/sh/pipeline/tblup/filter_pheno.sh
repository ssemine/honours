#!/bin/bash

# Creates a copy of the phenotype file with IIDs instead of barcodes
echo "Running map_iid_pheno.sh ..."
"$SH_TBLUP_UTILS_DIR/map_iid_pheno.sh" \
    --pheno-map "$PHENO_MAP" \
    --pheno-file "$PHENO_FILTERED_DATA" \
    --oii "$GENE_EXP_FILTERED_OII_DATA" \
    --out-pheno "$PHENO_IID_DATA"

# Creates a copy of the phenotype file with IIDs instead of barcodes
echo "Running map_iid_pheno.sh ..."
"$SH_TBLUP_UTILS_DIR/map_iid_pheno.sh" \
    --pheno-map "$PHENO_MAP" \
    --pheno-file "$PHENO_FILTERED_DATA" \
    --oii "$GENE_EXP_FILTERED_OII_DATA" \
    --out-pheno "$PHENO_IID_DATA"