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
is_intermediate=false

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
		--intermediate)
			is_intermediate=true
			shift 1
			;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

# Determine prefix
if $is_intermediate; then
    preprefix="" # empty for intermediate mode
else
    preprefix="final_"
fi

if [[ -n "$chr" ]]; then
    if [[ -n "$trm_cutoff" ]]; then
        prefix="${preprefix}chr${chr}_cut${trm_cutoff}"
    else
        prefix="${preprefix}chr${chr}"
    fi
else
    if [[ -n "$trm_cutoff" ]]; then
        prefix="${preprefix}cut${trm_cutoff}"
    else
        prefix="${preprefix}nocut"
    fi
fi

if [[ -n "$chr" ]]; then
    # Chromosome-specific TRM
    if $is_intermediate; then
        prefix_dir="$INTERMEDIATE_DIR/$prefix"
        mkdir -p "$prefix_dir"
        out_befile="$prefix_dir/$prefix"_"$(basename "$befile")"
        out_trm="$prefix_dir/$prefix"_"$(basename "$out_trm")"
    else
        out_befile="$GENE_EXP_FINAL_DIR/$prefix"_"$(basename "$befile")"
        out_trm="$GENE_EXP_FINAL_DIR/$prefix"_"$(basename "$out_trm")"
    fi
    osca \
        --befile "$befile" \
        --chr "$chr" \
        --make-bod \
        --out "$out_befile"
    befile="$out_befile" # need to change
else
    # Autosome TRM
    if $is_intermediate; then
        prefix_dir="$INTERMEDIATE_DIR/$prefix"
        mkdir -p "$prefix_dir"
        for ext in bod oii opi; do
            src_file="${befile}.${ext}"
            [[ -f "$src_file" ]] || continue
            cp "$src_file" "$prefix_dir/$prefix"_"$(basename "$befile").${ext}"
        done
        befile="$prefix_dir/$prefix"_"$(basename "$befile")"
        out_trm="$prefix_dir/$prefix"_"$(basename "$out_trm")"
    else
        if [[ -n "$trm_cutoff" ]]; then
            out_trm="$(dirname "$out_trm")/$prefix\_$(basename "$out_trm")"
        fi
    fi
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
