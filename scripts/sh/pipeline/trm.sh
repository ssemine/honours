#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

# make_trm.sh -> get_covar.sh -> get_pca.sh -> run_oreml.sh


# First, use GENE_EXP_FILTERED_DATA, then GENE_EXP_FINAL_DATA after outlier filtering

befile="$GENE_EXP_FILTERED_DATA"
is_intermediate=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --befile)
            befile="$2"
            shift 2
            ;;
    	--intermediate)
	    is_intermediate=true
	    shift 1
	    ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done
if $intermediate
echo "Running make_trm.sh for all data ..."
"$SH_UTILS_DIR/make_trm.sh" \
        --befile "$befile" \
        --trm-cutoff 1.00 \
        --out-trm "$TRM_DATA"

for chr in {1..29}; do
    echo "Running make_trm.sh for chromosome $chr ..."
    "$SH_UTILS_DIR/make_trm.sh" \
        --befile "$befile" \
        --chr "$chr" \
        --trm-cutoff 1.00 \
        --out-trm "$TRM_DATA"
done
