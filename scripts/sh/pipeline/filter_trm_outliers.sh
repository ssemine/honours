#!/bin/bash

shopt -s extglob nullglob # needed for regex

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"
source "$R_CONF"

module load "$OSCA_MODULE"
module load "$R_MODULE"

excl_iids="$EXCL_IIDS_TRM"
out_bod="$GENE_EXP_FINAL_BOD_DATA"
befiles=( "$GENE_EXP_DIR"/*"$GENE_EXP_FILTERED_FILENAME"* !(*.log) )
trms=( "$TRM_DIR"/*"$GENE_EXP_FILTERED_FILENAME"* !(*.log) )

for befile in "${befiles[@]}"; do
    osca \
        --befile "$befile" \
        --remove "$excl_iids" \
        --make-bod \
        --out "$out_bod":
done