#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pheno_file)
            pheno_file="$2"
            shift 2
            ;;
        --pheno_map)
            pheno_map="$2"
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
    -f "$AWK_SCRIPTS_DIR/barcode_to_iid.awk" \
    "$pheno_map" \
    "$pheno_file" \
    > "$out"