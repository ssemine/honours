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
        --out-trm)
            trm_out="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done
"$SH_UTILS_DIR/make_trm.sh" \
        --befile "$befile" \
        --trm-cutoff "$trm_cutoff" \
        --out-trm "$trm_out"