#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

# make_trm.sh -> get_covar.sh -> get_pca.sh -> run_oreml.sh


# First, use GENE_EXP_FILTERED_DATA, then GENE_EXP_FINAL_DATA after outlier filtering

is_intermediate=false
is_per_chr=false
trm_cutoff=1.00

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
        --trm-cutoff)
            trm_cutoff="$2"
            shift 2
            ;;
        --per-chr)
            is_per_chr=true
            shift 1
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done
if $is_intermediate; then
        echo "Intermediate mode enabled"
        rm -rf "$INTERMEDIATE_DIR"
        if $is_per_chr; then
                for chr in {1..29}; do
                        echo "Running make_trm.sh for chromosome $chr ..."
                        "$SH_UTILS_DIR/make_trm.sh" \
                                --befile "$befile" \
                                --chr "$chr" \
                                --trm-cutoff "$trm_cutoff" \
                                --intermediate \
                                --out-trm "$TRM_DATA"
                done
        else
                echo "Running make_trm.sh for all data ..."
                "$SH_UTILS_DIR/make_trm.sh" \
                        --befile "$befile" \
                        --trm-cutoff "$trm_cutoff" \
                        --intermediate \
                        --out-trm "$TRM_DATA"
        fi
else
        echo "Intermediate mode disabled"
        if $is_per_chr; then
                for chr in {1..29}; do
                        echo "Running make_trm.sh for chromosome $chr ..."
                        "$SH_UTILS_DIR/make_trm.sh" \
                                --befile "$befile" \
                                --chr "$chr" \
                                --trm-cutoff "$trm_cutoff" \
                                --out-trm "$TRM_DATA"
                done
        else
                echo "Running make_trm.sh for all data ..."
                "$SH_UTILS_DIR/make_trm.sh" \
                        --befile "$befile" \
                        --trm-cutoff "$trm_cutoff" \
                        --out-trm "$TRM_DATA"
        fi
fi