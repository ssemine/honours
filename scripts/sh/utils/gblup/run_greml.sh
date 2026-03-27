#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$GCTA_CONF"

module load "$GCTA_MODULE"

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
        --grm)
            grm="$2"
            shift 2
            ;;
        --grm-flist)
            grm_flist="$2"
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

if [[ -n "$grm_flist" ]]; then
    if [[ -n "$covar_file" && -n "$qcovar_file" ]]; then
        gcta64 \
            --reml \
            --mgrm "$grm_flist" \
            --covar "$covar_file" \
            --qcovar "$qcovar_file" \
            --out "$out" \
            --pheno "$pheno"
    elif [[ -n "$covar_file" ]]; then
        gcta64 \
            --reml \
            --mgrm "$grm_flist" \
            --covar "$covar_file" \
            --out "$out" \
            --pheno "$pheno"
    elif [[ -n "$qcovar_file" ]]; then
        gcta64 \
            --reml \
            --mgrm "$grm_flist" \
            --qcovar "$qcovar_file" \
            --out "$out" \
            --pheno "$pheno"
    else
        gcta64 \
            --reml \
            --mgrm "$grm_flist" \
            --out "$out" \
            --pheno "$pheno"
    fi
elif [[ -n "$grm" ]]; then
    if [[ -n "$covar_file" && -n "$qcovar_file" ]]; then
        gcta64 \
            --reml \
            --grm "$grm" \
            --covar "$covar_file" \
            --qcovar "$qcovar_file" \
            --out "$out" \
            --pheno "$pheno"
    elif [[ -n "$covar_file" ]]; then
        gcta64 \
            --reml \
            --grm "$grm" \
            --covar "$covar_file" \
            --out "$out" \
            --pheno "$pheno"
    elif [[ -n "$qcovar_file" ]]; then
        gcta64 \
            --reml \
            --grm "$grm" \
            --qcovar "$qcovar_file" \
            --out "$out" \
            --pheno "$pheno"
    else
        gcta64 \
            --reml \
            --grm "$grm" \
            --out "$out" \
            --pheno "$pheno"
    fi
else
    exit 1
fi