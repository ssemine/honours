#!/bin/bash

source /home/s4693165/honours/config/paths.conf

# Call probes from initial autosome expression profile
"$SH_UTILS_DIR/get_mean_var.sh" --befile "$GENE_EXP_FILTER_BOD_NA_PHENO_DATA" --out $PROBES_DIR/initial_auto

# Call probes from final filtered with 1.00 relatedness
final_data="$GENE_EXP_FINAL_DIR/final_cut1.00_filtered_finalprofile.v2"
"$SH_UTILS_DIR/get_mean_var.sh" --befile "$GENE_EXP_STD_DATA" --out $PROBES_DIR/final
