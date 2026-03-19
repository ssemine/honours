#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"
source "$R_CONF"

module load "$OSCA_MODULE"
module load "$R_MODULE"

log2_transform=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --befile)
            befile="$2"
            shift 2
            ;;
        --log2-transform)
            log2_transform=true
            shift 1
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

txt_profile="$INTERMEDIATE_DIR/$befile.txt"
txt_profile_transformed="$INTERMEDIATE_DIR/$befile.transformed.txt"

if [ "$log2_transform" = true ]; then
    osca --befile "$befile" --make-efile --out "$txt_profile"
    Rscript "/home/s4693165/honours/scripts/R/tblup/utils/cpm_transform.R" \
        --input "$txt_profile" \
        --output "$txt_profile_transformed"
    osca --efile "$txt_profile_transformed" --gene-expression --make-bod --out "$out_bod"
    osca --befile "$out_bod" --update-opi "$befile.opi"
fi