#!/bin/bash

shopt -s nullglob globstar # needed for regex

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"
source "$R_CONF"

module load "$OSCA_MODULE"
module load "$R_MODULE"

excl_iids="$EXCL_IIDS_TRM"

for dir in "$INTERMEDIATE_DIR"/**/; do
    [[ -d "$dir" ]] || continue

    trm_file=("$dir"*trm*)
    [[ -f "${trm_file[0]}" ]] || continue # skip

    trm_base=$(basename "${trm_file[0]}")
    trm_prefix="${trm_base%%trm*}trm" 

    # hardcoded to avoid checking .log
    befile=("$dir"*filtered_finalprofile.v2.oii)
    [[ -f "${befile[0]}" ]] || continue

    befile_base=$(basename "${befile[0]}")
    befile_prefix="${befile_base%%.*}"  
    
    Rscript "$R_TBLUP_DIR/iqr_outliers.R" "$dir$befile_prefix" > "$excl_iids"
    
    osca \
        --befile "$befile" \
        --remove "$excl_iids" \
        --make-bod \
        --out "$GENE_EXP_DIR/final_$befile_prefix" # figure out how to name this
done  