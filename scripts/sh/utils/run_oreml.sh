#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pheno)
            pheno="$2"
            shift 2
            ;;
        --covar-file)
            covar_file="$2"
            shift 2
            ;;
        --qcovar-file)
            qcovar_file="$2"
            shift 2
            ;;
        --trm)
            trm="$2"
            shift 2
            ;;
        --trm-flist)
            trm_flist="$2"
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

if [[ -n "$trm_flist" ]]; then
    if [[ -n "$covar_file" && -n "$qcovar_file" ]]; then
        osca \
            --reml \
            --multi-orm "$trm_flist" \
            --covar "$covar_file" \
            --qcovar "$qcovar_file" \
            --out "$out"
    elif [[ -n "$covar_file" ]]; then
        osca \
            --reml \
            --multi-orm "$trm_flist" \
            --covar "$covar_file" \
            --out "$out"
    elif [[ -n "$qcovar_file" ]]; then
        osca \
            --reml \
            --multi-orm "$trm_flist" \
            --qcovar "$qcovar_file" \
            --out "$out"
    else
        osca \
            --reml \
            --multi-orm "$trm_flist" \
            --out "$out"
    fi
elif [[ -n "$trm" ]]; then
    if [[ -n "$covar_file" && -n "$qcovar_file" ]]; then
        osca \
            --reml \
            --orm "$trm" \
            --covar "$covar_file" \
            --qcovar "$qcovar_file" \
            --out "$out"
    elif [[ -n "$covar_file" ]]; then
        osca \
            --reml \
            --orm "$trm" \
            --covar "$covar_file" \
            --out "$out"
    elif [[ -n "$qcovar_file" ]]; then
        osca \
            --reml \
            --orm "$trm" \
            --qcovar "$qcovar_file" \
            --out "$out"
    else
        osca \
            --reml \
            --orm "$trm" \
            --out "$out"
    fi
else
    exit 1
fi