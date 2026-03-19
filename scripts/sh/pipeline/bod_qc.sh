#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"
source "$R_CONF"

module load "$OSCA_MODULE"
module load "$R_MODULE"

log2_transform=false
qc=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --befile)
            befile="$2"
            shift 2
            ;;
        --qc)
            qc=true
            shift 1
            ;;
        --sd-min)
            sd_min="$2"
            shift 2
            ;;
        --missing-ratio-probe)
            missing_ratio_probe="$2"
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

if [ "$qc" = true ]; then
    osca --befile "$befile" --sd-min "$sd_min" --make-bod --out "$befile.sdmin"
    osca --befile "$befile.sdmin" --missing-ratio-probe "$missing_ratio_probe" --make-bod --out "$befile.mrp"
    new_befile="$befile.mrp"
    befile="$new_befile"
fi

txt_profile="$befile.txt"
txt_profile_transformed="$befile.transformed.txt"

if [ "$log2_transform" = true ]; then
    osca --befile "$befile" --make-efile --out "$txt_profile"
    Rscript "/home/s4693165/honours/scripts/R/tblup/utils/cpm_transform.R" \
        --input "$txt_profile" \
        --output "$txt_profile_transformed"
    osca --efile "$txt_profile_transformed" --gene-expression --make-bod --out "$out_bod"
    osca --befile "$out_bod" --update-opi "$befile.opi"
fi