#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$SLURM_CONF"

initial_befile="$GENE_EXP_BFILE"
auto_gene_list="$GENE_EXP_AUTO_GENE_LIST"
auto_befile="$GENE_EXP_AUTO_DATA"
pheno_map="$PHENO_MAP"
pheno_file="$PHENO_FILE"
excl_iids_not_shared="$GENE_EXP_EXCL_IIDS_BOD_PHENO"
shared_befile="$GENE_EXP_FILTER_BOD_PHENO_DATA"
shared_pheno="$PHENO_FILTERED_DATA"
iid_pheno="$PHENO_IID_DATA"
no_na_befile="$GENE_EXP_FILTER_BOD_NA_PHENO_DATA"
afc_900_befile="$GENE_EXP_FILTER_BOD_900_PHENO_DATA"
std_befile="$GENE_EXP_STD_DATA"

args_arr=( \
  --initial-befile "$initial_befile" \
  --auto-gene-list "$auto_gene_list" \
  --auto-befile "$auto_befile" \
  --pheno-map "$pheno_map" \
  --pheno "$pheno_file" \
  --excl-iids-not-shared "$excl_iids_not_shared" \
  --shared-befile "$shared_befile" \
  --shared-pheno "$shared_pheno" \
  --iid-pheno "$iid_pheno" \
  --no-na-befile "$no_na_befile" \
  --afc-900-befile "$afc_900_befile" \
  --std-befile "$std_befile" \
)

sbatch \
  --account="$ACCOUNT_STRING" \
  --partition="$PARTITION" \
  --cpus-per-task="$CPUS" \
  --mem="$MEM_MAKE_TRM" \
  --time="$TIME" \
  --output="$LOGS_TBLUP_DIR/%x_%j.out" \
  --error="$LOGS_TBLUP_DIR/%x_%j.err" \
  --job-name="bod_assembly" \
  --wrap="/home/s4693165/honours/scripts/sh/pipeline/filter.sh ${args_arr[@]}"
