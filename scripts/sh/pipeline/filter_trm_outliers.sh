#!/bin/bash

shopt -s nullglob globstar # needed for regex

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"
source "$R_CONF"

module load "$OSCA_MODULE"
module load "$R_MODULE"

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
        --excl-iids)
            excl_iids="$2"
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