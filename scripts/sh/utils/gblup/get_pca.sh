#!/bin/bash

# get_pca.sh
#
# Calculates PCA values
#
# Input arguments:
#   --grm: Input GRM file
#   --n-pca: Number of PCs
#   --out-pca: Output PCA file
# Output files:
#   PCA files (.eigenvec and .eigenval files)

source /home/s4693165/honours/config/paths.conf
source "$GCTA_CONF"

module load "$GCTA_MODULE"

while [[ $# -gt 0 ]]; do
    case "$1" in
		--grm)
			grm="$2"
			shift 2
			;;
		--n-pca)
			n_pca="$2"
			shift 2
			;;
		--out-pca)
			out_pca="$2"
			shift 2
			;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

gcta64 \
    --grm "$trm" \
    --pca "$n_pca" \
    --out "$out_pca" \
	--autosome-num 29 \
	--autosome 