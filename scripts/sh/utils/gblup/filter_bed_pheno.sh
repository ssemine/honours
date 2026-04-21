#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$GCTA_CONF"

module load "$GCTA_MODULE"

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
		--bfile)
			bfile="$2"
			shift 2
			;;
		--excl-iids)
			excl_iids="$2"
			shift 2
			;;
		--fam)
			fam="$2"
			shift 2
			;;
		--out-bed)
			out_bed="$2"
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
	"$fam" \
	"$pheno_map" \
	"$pheno_file"

gcta64 \
	--bfile "$bfile" \
    --autosome-num 29 \
	--remove "$excl_iids" \
	--make-bed \
	--out "$out_bed"