#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"
source "$BOD_CONF"
source "$OSCA_CONF"

module load "$OSCA_MODULE"

# temporary
pheno_name="afc_"
pheno_idx=8
befile="$GENE_EXP_FILTERED_AUTOSOME_DATA"
excl_iids_filename="excluded_iids.list"
excl_iids="$GENE_EXP_DIR/$pheno_name$excl_iids_filename"
output_profile="$GENE_EXP_FILTERED_AUTOSOME_AFC_DATA"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pheno-prefix)
            pheno_prefix="$2"
            shift 2
            ;;
        --pheno-idx)
            pheno_idx="$2"
            shift 2
            ;;
		--pheno-map)
			pheno_map="$2"
			shift 2
			;;
		--pheno-file)
			pheno_file="$2"
			shift 2
			;;
		--befile)
			befile="$2"
			shift 2
			;;
		--excl-iids)
			excl_iids="$2"
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

gawk \
	-v phenoIdx="$pheno_idx" \
	-f "$AWK_SCRIPTS_DIR/filter_bod_na_pheno.awk" \
	"$pheno_map" \
	"$pheno_file" \
	> "$excl_iids"

osca --befile "$befile" --remove "$excl_iids" --make-bod --out "$out_bod"

