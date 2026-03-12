#!/bin/bash

# filter_bod_pheno.sh
# 
# Filters both the BOD .oii and the phenoptype files
# Usage: ./filter_bod_pheno.sh

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

# temporary
excl_iids="$GENE_EXP_DIR/excluded_iids.list"

while [[ $# -gt 0 ]]; do
    case "$1" in
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
		--out-pheno)
			out_pheno="$2"
			shift 2
			;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

gawk \
	-v out_pheno="$out_pheno" \
	-v out_missing="$excl_iids" \
	-f "$AWK_SCRIPTS_DIR/filter_bod_pheno.awk" \
	"$GENE_EXP_OII_DATA" \
	"$pheno_map" \
	"$pheno_file"

osca \
	--befile "$befile" \
	--remove "$excl_iids" \
	--make-bod \
	--out "$out_bod"