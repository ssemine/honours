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
intermediate=false

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

# Creates intermediate directory
if $is_intermediate; then
	out_trm="$INTERMEDIATE_DIR/$(basename "$out_trm")"
	out_befile="$INTERMEDIATE_DIR/$(basename "$befile")"
	mkdir -p "$INTERMEDIATE_DIR"
	rm -rf "$INTERMEDIATE_DIR"/*
fi

if [[ -n "$chr" ]]; then
	# Chromosome-specific TRM
	if [[ -n "$trm_cutoff" ]]; then
		if $is_intermediate; then
			prefix="chr${chr}_cut${trm_cutoff}"
			mkdir -p "$INTERMEDIATE_DIR/$prefix"
			out_befile="$INTERMEDIATE_DIR/$prefix/$prefix"_"$(basename "$befile")"
			out_trm="$INTERMEDIATE_DIR/$prefix/$prefix"_"$(basename "$out_trm")"
		else
			out_befile="$(dirname "$befile")/$prefix"_"$(basename "$befile")"
			out_trm="$(dirname "$out_trm")/$prefix"_"$(basename "$out_trm")"
		fi
	else
		if $is_intermediate; then
			prefix="chr${chr}"
			mkdir -p "$INTERMEDIATE_DIR/$prefix_"
			out_befile="$INTERMEDIATE_DIR/$prefix/$prefix"_"$(basename "$befile")"
			out_trm="$INTERMEDIATE_DIR/$prefix/$prefix"_"$(basename "$out_trm")"
		else
			out_befile="$(dirname "$befile")/$prefix"_"$(basename "$befile")"
			out_trm="$(dirname "$out_trm")/$prefix"_"$(basename "$out_trm")"
		fi
	fi
	osca \
		--befile "$befile" \
		--chr "$chr" \
		--make-bod \
		--out "$out_befile"
	befile="$out_befile"
else
	# Autosome TRM 
	if [[  -n "$trm_cutoff" ]]; then
		if $is_intermediate; then
			prefix="cut${trm_cutoff}"
			dest_dir="$INTERMEDIATE_DIR/$prefix"
			mkdir -p "$dest_dir"
			for ext in bod oii opi; do
				src_file="${befile}.${ext}"
				[[ -f "$src_file" ]] || continue
				cp "$src_file" "$dest_dir/$prefix"_"$(basename "$befile").${ext}"
			done
			befile="$INTERMEDIATE_DIR/$prefix/$prefix"_"$(basename "$befile")"
			out_trm="$INTERMEDIATE_DIR/$prefix/$prefix"_"$(basename "$out_trm")"
		else
			out_trm="$(dirname "$out_trm")/$prefix\_$(basename "$out_trm")"
		fi
	else
		if $is_intermediate; then
			prefix="nocut"
			dest_dir="$INTERMEDIATE_DIR/$prefix"
			mkdir -p "$dest_dir"
			for ext in bod oii opi; do
				src_file="${befile}.${ext}"
				[[ -f "$src_file" ]] || continue
				cp "$src_file" "$dest_dir/$prefix"_"$(basename "$befile").${ext}"
			done
			befile="$INTERMEDIATE_DIR/$prefix/$prefix"_"$(basename "$befile")"
			out_trm="$INTERMEDIATE_DIR/$prefix/$prefix"_"$(basename "$out_trm")"
		else
			out_trm="$(dirname "$out_trm")/$(basename "$out_trm")"
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
