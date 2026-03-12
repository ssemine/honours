#!/bin/bash

source /home/s4693165/honours/config/paths.conf

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pheno-idx)
            pheno_idx="$2"
            shift 2
            ;;
        --pheno-file)
            pheno_file="$2"
            shift 2
            ;;
        --iid-idx)
            iid_idx="$2"
            shift 2
            ;;
        --out-pheno)
            out_pheno="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

gawk \
    -f "$AWK_SCRIPTS_DIR/make_oreml_pheno.awk" \
    -v pheno_idx="$pheno_idx" \
    -v iid_idx="$iid_idx" \
    "$pheno_file" \
    > "$out_pheno"