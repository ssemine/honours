#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

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
		--out-bod)
			out_bod="$2"
			shift 2
			;;
		--n-chr)
			n_chr="$2"
			shift 2
			;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

for n in {1..$n_chr}; do
	osca --befile "$befile" --chr $n --make-bod --out "$(dirname "$out_bod")/chr${n}_$(basename "$out_bod")"
done