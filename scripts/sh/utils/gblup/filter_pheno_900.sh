#!/bin/bash


source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"
source "$GCTA_CONF"

module load "$GCTA_MODULE"

excl_iids="$EXCL_IIDS_900"

while [[ $# -gt 0 ]]; do
    case "$1" in
		--bfile)
			bfile="$2"
			shift 2
			;;
		--out-bed)
			out_bed="$2"
			shift 2
			;;
        --excl-iids)
            excl_iids="$2"
            shift 2
            ;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

# FIX MY ARG INDEX
gawk 'NR>1 && $8 < 900 {print $1, $1}' "$PHENO_IID_DATA" > "$excl_iids"

gcta64 \
	--bfile "$bfile" \
	--remove "$excl_iids" \
	--autosome-num 29 \
	--make-bed \
	--out "$out_bed"