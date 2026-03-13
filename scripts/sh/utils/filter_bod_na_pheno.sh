#!/bin/bash

# filter_bod_pheno.sh
#
# Filters both the BOD and phenotype files for NA values, specifically AFC
#
# Input arguments:
#   --pheno-idx: Phenotype index
#   --pheno-map: Phenotype map file
#   --pheno-file: Phenotype file
#   --befile: Input BOD file
#   --excl-iids: Excluded IIDs file
#   --out-bod: Output BOD file
# Output files:
#   Filtered BOD files (.bod, .opi, .oii)
#   Filtered phenotype file (.txt)

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"
source "$BOD_CONF"
source "$OSCA_CONF"

module load "$OSCA_MODULE"

while [[ $# -gt 0 ]]; do
    case "$1" in
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

osca \
	--befile "$befile" \
	--remove "$excl_iids" \
	--make-bod \
	--out "$out_bod"

