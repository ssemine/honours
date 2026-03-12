#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

osca --befile "$GENE_EXP_FINAL_AFC_DATA" --std-probe --make-bod --out "$GENE_EXP_STD_AFC_DATA"
