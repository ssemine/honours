#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

trm_cutoff=""
trm=""
trm_dir=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --trm)
            trm="$2"
            shift 2
            ;;
        --trm-cutoff)
            trm_cutoff="$2"
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
    --orm "$trm" \
    --orm-cutoff "$trm_cutoff" \
    --make-orm \
    --out "$(dirname "$out_trm")/cut${trm_cutoff}_$(basename "$out_trm")"