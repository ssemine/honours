#!/bin/bash

source /home/s4693165/honours/config/paths.conf

while [[ $# -gt 0 ]]; do
    case "$1" in
        --oii)
            oii="$2"
            shift 2
            ;; 
        --pheno-iid)
            pheno_iid="$2"
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
    -f "$AWK_SCRIPTS_DIR/get_oreml_pheno.awk" \
    "$oii" \
    "$pheno_iid" \
    > "$out_pheno" 