#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"
source "$OSCA_CONF"

module load "$OSCA_MODULE"

excl_iids="$EXCL_IIDS_NA"

while [[ $# -gt 0 ]]; do
    case "$1" in
		--befile)
			befile="$2"
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

# FIX MY ARG INDEX
gawk 'NR>1 && $8=="NA" {print $1, $1}' "$PHENO_IID_DATA" > "$excl_iids"

osca \
	--befile "$befile" \
	--remove "$excl_iids" \
	--make-bod \
	--out "$out_bod"