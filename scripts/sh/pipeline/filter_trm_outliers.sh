#!/bin/bash

shopt -s nullglob globstar # needed for regex

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"
source "$R_CONF"

module load "$OSCA_MODULE"
module load "$R_MODULE"

excl_iids="$EXCL_IIDS_TRM"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --befile)
            befile="$2"
            shift 2
            ;; 
        --trm)
            trm="$2"
            shift 2
            ;;
        --out-bod)
            out_bod="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

Rscript "/home/s4693165/honours/scripts/R/tblup/utils/iqr_outliers.R" "$trm" > "$excl_iids"
         
osca \
    --befile "$befile" \
    --remove "$excl_iids" \
    --make-bod \
    --out "$out_bod"

    # for dir in "$INTERMEDIATE_DIR"/**/; do
    #     [[ -d "$dir" ]] || continue
    # 
    #     trm_file=("$dir"*trm*)
    #     [[ -f "${trm_file[0]}" ]] || continue # skip
    # 
    #     trm_base=$(basename "${trm_file[0]}")
    #     trm_prefix="${trm_base%%trm*}trm" 
    # 
    #     # hardcoded to avoid checking .log
    #     befile=("$dir"*filtered_finalprofile.v2.oii)
    #     [[ -f "${befile[0]}" ]] || continue
    # 
    #     befile_base=$(basename "${befile[0]}")
    #     befile_prefix="${befile_base%.*}"
    #     
    #     Rscript "$R_UTILS_DIR/iqr_outliers.R" "$dir$trm_prefix" > "$excl_iids"
    #     
    #     osca \
    #         --befile "$dir$befile_prefix" \
    #         --remove "$excl_iids" \
    #         --make-bod \
    #         --out "$GENE_EXP_FINAL_DIR/final" # figure out how to name this
    # done

