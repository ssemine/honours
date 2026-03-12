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
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

osca \
	--befile "$befile" \
	--make-orm \
	--orm-alg "$orm_alg" \
	--out "$(dirname "$out_trm")/chr${n}_$(basename "$out_trm")"
