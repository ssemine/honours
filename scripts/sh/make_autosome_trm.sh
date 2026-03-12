#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

gene_exp_data="$GENE_EXP_STD_AFC_DATA" # either filtered or not

osca --befile "$gene_exp_data" --make-orm --orm-alg "$ORM_ALG_STANDARD" --out "$TBLUP_TRM_DIR/trm_std_standard"

