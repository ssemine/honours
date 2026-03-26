#!/bin/bash

# exclude_sex_chr.sh
#
# Excludes sex chromosomes from BOD files
#
# Input arguments:
#   --befile: Input BOD file
#   --opi: BOD .opi file
#   --out-gene-list: Output gene list file
#   --out-bod: Output BOD file
# Output files:
#   Filtered BOD files (.bod, .opi, .oii)
#   Gene list file (.txt) (Intermeediate)

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --befile)
            befile="$2"
            shift 2
            ;;
        --opi)
            opi="$2"
            shift 2
            ;;
		--out-gene-list)
			out_gene_list="$2"
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

gawk \
	-f "$AWK_SCRIPTS_DIR/exclude_sex_chr.awk" \
	"$opi" \
	> "$out_gene_list"

osca \
	--befile "$befile" \
	--genes "$out_gene_list" \
	--make-bod \
	--out "$out_bod"