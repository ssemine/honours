#!/bin/bash

source /home/s4693165/honours/config/paths.conf

# temporary
oii_file="$GENE_EXP_FILTERED_AUTOSOME_AFC_OII_DATA"

while [[ $# -gt 0 ]]; do
    case "$1" in
		--pheno-map)
			pheno_map="$2"
			shift 2
			;;
		--oii)
			oii_file="$2"
			shift 2
			;;
		--pheno-file)
			pheno_file="$2"
			shift 2
			;;
		--out)
			out="$2"
			shift 2
			;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

gawk \
	-f "$AWK_SCRIPTS_DIR/map_iid_pheno.awk" \
	"$pheno_map" \
	"$oii_file" \
	"$pheno_file" \
	> "$out"