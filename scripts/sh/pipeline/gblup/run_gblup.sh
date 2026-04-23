#!/bin/bash

# match iids with phenotype of interest

# run qc:
#   1) maf < 5% or 1%
#   2) missingness, relatedness, etc.
# standardise
# prepare GRM
# prepare covariates
# run GREML

source /home/s4693165/honours/config/paths.conf

source "$PLINK_CONF"
source "$GCTA_CONF"

module load "$PLINK_MODULE"
module load "$GCTA_MODULE"

initial_bfile="$GENE_EXP_FILTER_BOD_900_PHENO_DATA" # change
bfile="$intitial_bfile"
initial_pheno="$PHENO_IID_DATA"
categorical_covar_indices=($CG_IDX $MATE_IN_DATE_IDX $CALF_SEX_IDX $YEAR_MATE_IDX $HEF_PREG_SUCCESS_IDX $HEF_WKS_PREG_BIN_IDX)
quantitative_covar_indices=($HEIFER_AGE_JOINING_IDX $HEF_WKS_PREG_IDX)
indi_missingness=0.1
hetzyg="heterozygosity"
maf_thresh=0.01
snp_missingness=0.05
hwe_thresh=1e-6 # check if works in PLINK

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
        --pca)
            use_pca=true
            shift 1
            ;;
        --hetzyg)
            use_hetzyg=true
            shift 1
            ;;
        --maf)
            maf_thresh="$2"
            shift 2
            ;;
        --snp-missingness)
            snp_missingness="$2"
            shift 2
            ;;
        --hwe)
            hwe_thresh="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [ "$use_covar" = true ]; then
    source "$covar_idx_file" # sources covars variable, ignored by git
    if [ ! -s "$covar_idx_file" ]; then
        echo -e "\nCovar file does not exist or empty\n"
    fi
fi
if [ "${#covars[@]}" -gt 0 ]; then
    covar_prefix=$(IFS=_ ; echo "${covars[*]}")
else
    covar_prefix=""
fi
if [ -n "$n_pca" ]; then
    pca_prefix="pca${n_pca}"
else
    pca_prefix=""
fi
dir_suffix=""
if [ -n "$covar_prefix" ] && [ -n "$pca_prefix" ]; then
    dir_suffix="${covar_prefix}_${pca_prefix}"
elif [ -n "$covar_prefix" ]; then
    dir_suffix="$covar_prefix"
elif [ -n "$pca_prefix" ]; then
    dir_suffix="$pca_prefix"
fi
gblup_suffix="gblup"
if [ -n "$dir_suffix" ]; then
    intermediate_dir="$INTERMEDIATE_DIR/$gblup_suffix/cut_${grm_cutoff}_$dir_suffix"
    results_dir="$RESULTS_DIR/$gblup_suffix/cut_${grm_cutoff}_$dir_suffix"
else
    intermediate_dir="$INTERMEDIATE_DIR/$gblup_suffix/cut_${grm_cutoff}"
    results_dir="$RESULTS_DIR/$gblup_suffix/cut_${grm_cutoff}"
fi
rm -rf "$intermediate_dir"
rm -rf "$results_dir"
covars_dir="$intermediate_dir/covars"
mkdir -p "$covars_dir"
mkdir -p "$intermediate_dir"
mkdir -p "$results_dir"

# QC Variables
greml_pheno_data="$results_dir/greml_pheno_data_${grm_cutoff}.phen"
pca_data="$intermediate_dir/pca_${grm_cutoff}"
final_bfile="$results_dir/final_bfile"
final_bfile_tmp="$intermediate_dir/final_bfile_tmp"
qcovar_file="$results_dir/qcovar.qcovar"
covar_file="$results_dir/covar.covar"

# PLINK QC
plink --bfile "$bfile" --mind "$indi_missingness" --make-bed --out "$bfile.step1"
plink --bfile "$bfile.step1" --check-sex --out "$bfile.step2"

if [ "$use_hetzyg" = true ]; then
    plink --bfile "$bfile.step2" --het --out "$hetzyg" # filter out with awk

    gawk '
    NR > 1 {
        f[NR] = $6
        id[NR] = $1 " " $2
        sum += $6
        sumsq += ($6)^2
    }
    END {
        n = NR - 1
        mean = sum / n
        sd = sqrt((sumsq / n) - (mean^2))

        lower = mean - 3*sd
        upper = mean + 3*sd

        for (i = 2; i <= NR; i++) {
            if (f[i] < lower || f[i] > upper) {
                print id[i]
            }
        }
    }' "$hetzyg" > "$hetzyg.out"
    plink --bfile "$bfile.step2" --remove "$hetzyg.out" --make-bed --out "$bfile.step3"
else
    cp "$bfile.step2.bed" "$bfile.step3.bed"
    cp "$bfile.step2.bim" "$bfile.step3.bim"
    cp "$bfile.step2.fam" "$bfile.step3.fam"
fi

plink --bfile "$bfile.step3" --maf "$maf_thresh" --make-bed --out "$bfile.step4"
plink --bfile "$bfile.step4" --geno "$snp_missingness" --make-bed --out "$bfile.step5"
plink --bfile "$bfile.step5" --hwe "$hwe_thresh" --make-bed --out "$bfile.step6"

bfile="$bfile.step6"
# run PCA on $bfile.step6
#if [ "$use_pca" = true ]; then
    #plink --bfile "$bfile.step"
#fi

# GRM Assembly
gcta64 --bfile "$bfile" --autosome --make-grm --out "$grm"
if [ "$grm_cutoff" = "nocut" ]; then
    gcta64 \
        --bfile "$bfile" \
        --make-grm \
        --out "$results_dir/grm"
else
    gcta64 \
        --bfile "$bfile" \
        --make-grm \
        --out "$results_dir/grm_uncut"
    gcta64 \
        --grm "$results_dir/grm_uncut" \
        --grm-cutoff "$grm_cutoff" \
        --out "$results_dir/grm"
fi

# change to gcta or generalise 
"$SH_TBLUP_UTILS_DIR/get_oreml_pheno.sh" \
    --oii "$bfile.fam" \
    --pheno-iid "$initial_pheno" \
    --out-pheno "$greml_pheno_data"

# Add covariate ADAPT TO GCTA
if [ -n "$n_pca" ]; then
    "$SH_TBLUP_UTILS_DIR/get_pca.sh" \
        --trm "$results_dir/grm" \
        --out-pca "$pca_data" \
        --n-pca "$n_pca"
    if [ ! -s "$qcovar_file" ]; then
        cp "$pca_data.eigenvec" "$qcovar_file"
    else
        gawk '
            FNR==NR {pca[$1]=$0; next} 
            $1 in pca {
                split($0,a," ") 
                split(pca[$1],b," ") 
                out=a[1]                
                for(i=2;i<=length(a);i++) out=out" "a[i];
                for(i=3;i<=length(b);i++) out=out" "b[i];
                print out
            }
        ' "$pca_data.eigenvec" "$qcovar_file" > "$qcovar_file.tmp"
        mv "$qcovar_file.tmp" "$qcovar_file"
    fi
fi

# final
if [ -s "$covar_file" ] && [ ! -s "$qcovar_file" ]; then
    "$SH_GBLUP_UTILS_DIR/run_greml.sh" \
        --grm "$results_dir/grm" \
        --covar-file "$covar_file" \
        --pheno "$greml_pheno_data" \
        --out "$results_dir/sol"
elif [ ! -s "$covar_file" ] && [ -s "$qcovar_file" ]; then
    "$SH_GBLUP_UTILS_DIR/run_greml.sh" \
        --grm "$results_dir/grm" \
        --qcovar-file "$qcovar_file" \
        --pheno "$greml_pheno_data" \
        --out "$results_dir/sol"
elif [ -s "$covar_file" ] && [ -s "$qcovar_file" ]; then
    "$SH_GBLUP_UTILS_DIR/run_greml.sh" \
        --grm "$results_dir/grm" \
        --covar-file "$covar_file" \
        --qcovar-file "$qcovar_file" \
        --pheno "$greml_pheno_data" \
        --out "$results_dir/sol"
elif [ ! -s "$covar_file" ] && [ ! -s "$qcovar_file" ]; then
    "$SH_GBLUP_UTILS_DIR/run_greml.sh" \
        --grm "$results_dir/grm" \
        --out "$results_dir/sol" \
        --pheno "$greml_pheno_data"
fi