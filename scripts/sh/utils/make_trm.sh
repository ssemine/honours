#!/bin/bash

# make_trm.sh
#
# Makes TRM files
#
# Input arguments:
#   --befile: Input BOD file
#   --orm-alg: ORM algorithm (default: 1)
#   --out-trm: Output ORM (TRM) file
#   --chr: Chromosome number (optional)
#   --trm-cutoff: TRM cutoff value (optional)
# Output files:
#   ORM (TRM) file (ORM file)

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

orm_alg="$ORM_ALG_STANDARD"
while [[ $# -gt 0 ]]; do
    case "$1" in
		--befile)
			befile="$2"
			shift 2
			;;
		--orm-alg)
			orm_alg="$2"
			shift 2
			;;
		--out-trm)
			out_trm="$2"
			shift 2
			;;
		--chr)
			chr="$2"
			shift 2
			;;
		--trm-cutoff)
            trm_cutoff="$2"
            shift 2
            ;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

if [[ -n "$chr" ]]; then
	if [[ -n "$trm_cutoff" ]]; then
		out_befile="$(dirname "$befile")/chr${chr}_cut${trm_cutoff}_$(basename "$befile")"
		out_trm="$(dirname "$out_trm")/chr${chr}_cut${trm_cutoff}_$(basename "$out_trm")"
	else
		out_befile="$(dirname "$befile")/chr${chr}_$(basename "$befile")"
		out_trm="$(dirname "$out_trm")/chr${chr}_$(basename "$out_trm")"
	fi
	osca \
		--befile "$befile" \
		--chr "$chr" \
		--make-bod \
		--out "$out_befile"
	befile="$out_befile"
fi

if [[ -n "$trm_cutoff" ]]; then
	osca \
		--befile "$befile" \
		--make-orm \
		--orm-alg "$orm_alg" \
		--orm-cutoff "$trm_cutoff" \
		--out "$out_trm"
else
	osca \
		--befile "$befile" \
		--make-orm \
		--orm-alg "$orm_alg" \
		--out "$out_trm"
fi