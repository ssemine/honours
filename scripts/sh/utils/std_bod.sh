#!/bin/bash

# std_bod.sh
#
# Standardises BOD files
#
# Input arguments:
#   --befile: Input BOD files (.bod, .opi, .oii)
#   --std-alg: Standardisation algorithm (default: --std-probe)
#   --out-bod: Output BOD files (.bod, .opi, .oii)
# Output files:
#   Standardised BOD files (.bod, .opi, .oii)

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

# default option
std_alg="--std-probe"

while [[ $# -gt 0 ]]; do
    case "$1" in
		--befile)
			befile="$2"
			shift 2
			;;
		--std-alg)
            # --std-probe or --rint-probe
			std_alg="$2"
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

osca \
    --befile "$befile" \
    "$std_alg" \
	--make-bod \
    --out "$out_bod"