# match iids with phenotype of interest

# run qc:
#   1) maf < 5% or 1%
#   2) missingness, relatedness, etc.
# standardise
# prepare GRM
# prepare covariates
# run GREML

#!/bin/bash

source /home/s4693165/honours/config/paths.conf

source "$PLINK_CONF"
source "$GCTA_CONF"

module load "$PLINK_MODULE"
module load "$GCTA_MODULE"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --bfile)
            initial_bfile="$2"
            shift 2
            ;;
        --pheno)
            initial_pheno="$2"
            shift 2
            ;;
        --n-pca)
            n_pca="$2"
            shift 2
            ;;
        --grm-cutoff)
            grm_cutoff="$2"
            shift 2
            ;;
        --covars)
            covars="$2"
            read -a covars <<< "$covar"
            shift 2
            ;;
        --use-covar-idx-file)
            use_covar=true
            shift 1
            ;;
        --covar-idx-file)
            covar_idx_file="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# PLINK QC
plink --bfile "$bfile" --mind 0.1 --make-bed --out "$bfile"
plink --bfile "$bfile" --check-sex --out "$bfile"
plink --bfile "$bfile" --het --out heterozygosity # filter out with awk
plink --bfile "$bfile" --maf 0.01 --make-bed --out "$bfile"
plink --bfile "$bfile" --geno 0.05 --make-bed --out "$bfile"
plink --bfile "$bfile" --hwe 1e-6 --make-bed --out "$bfile"


# Assumes filtered for pheno BFILE
gcta64 --bfile "$bfile" --autosome --make-grm --out "$grm"

if [ -n "$grm_cutoff" ]; then   
    gcta64 --grm "$grm" --grm-cutoff "$grm_cutoff" --make-grm --out "$grm.tmp"
fi






# final
if [ -s "$covar_file" ] && [ ! -s "$qcovar_file" ]; then
    "$SH_GBLUP_UTILS_DIR/run_oreml.sh" \
    --trm "$results_dir/grm" \
    --covar-file "$covar_file" \
    --pheno "$greml_pheno_data" \
    --out "$results_dir/sol"
elif [ ! -s "$covar_file" ] && [ -s "$qcovar_file" ]; then
    "$SH_GBLUP_UTILS_DIR/run_oreml.sh" \
    --trm "$results_dir/grm" \
    --qcovar-file "$qcovar_file" \
    --pheno "$greml_pheno_data" \
    --out "$results_dir/sol"
elif [ -s "$covar_file" ] && [ -s "$qcovar_file" ]; then
    "$SH_GBLUP_UTILS_DIR/run_oreml.sh" \
    --trm "$results_dir/grm" \
    --covar-file "$covar_file" \
    --qcovar-file "$qcovar_file" \
    --pheno "$greml_pheno_data" \
    --out "$results_dir/sol"
elif [ ! -s "$covar_file" ] && [ ! -s "$qcovar_file" ]; then
    "$SH_GBLUP_UTILS_DIR/run_oreml.sh" \
    --trm "$results_dir/grm" \
    --out "$results_dir/sol" \
    --pheno "$greml_pheno_data"
fi