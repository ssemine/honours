#!/bin/bash

# get_covar.sh
#
# Fetches a single covariate from the phenotype file, to be used in OREML
#
# Input arguments:
#   --pheno-file: Phenotype file
#   --iid-idx: IID index
#   --covar_idx: Covariate index
#	--oii: OII file
#   --out: Output file
# Output files:
#   Covariate file (.covar)

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

while [[ $# -gt 0 ]]; do
    case "$1" in
		--pheno-file)
			pheno_file="$2"
			shift 2
			;;
        --iid-idx)
            iid_idx="$2"
            shift 2
            ;;
		--covar-idx)
			covar_idx="$2"
			shift 2
			;;
		-oii)
			oii_file="$2"
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
    -f "$AWK_SCRIPTS_DIR/get_covar.awk" \
    -v iid_idx="$iid_idx" \
    -v covar_idx="$covar_idx" \
	"$oii_file" \
    "$pheno_file" \
    > "$out"