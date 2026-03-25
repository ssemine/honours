#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"
source "$R_CONF"
source "$SH_UTILS_DIR/helper_functions.sh"
source "$PHENO_CONF"

module load "$OSCA_MODULE"
module load "$R_MODULE"

log2_transform=false
qc=true
iqr=false
pc1=false
use_covar=false
sd_min=0.02
missing_ratio_probe=0.05

initial_befile="$GENE_EXP_FILTER_BOD_900_PHENO_DATA"
initial_pheno="$PHENO_IID_DATA"
categorical_covar_indices=($CG_IDX $MATE_IN_DATE_IDX $CALF_SEX_IDX $YEAR_MATE_IDX $HEF_PREG_SUCCESS_IDX $HEF_WKS_PREG_BIN_IDX)
quantitative_covar_indices=($HEIFER_AGE_JOINING_IDX $HEF_WKS_PREG_IDX)

while [[ $# -gt 0 ]]; do
    case "$1" in
        --befile)
            initial_befile="$2"
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
        --trm-cutoff)
            trm_cutoff="$2"
            shift 2
            ;;
        --log2-transform)
            log2_transform=true
            shift 1
            ;;
        --qc)
            qc=true
            shift 1
            ;;
        --iqr)
            iqr=true
            shift 1
            ;;
        --pc1)
            pc1=true
            shift 1
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

if [ "$log2_transform" = true ]; then
    log_prefix="log_"
else
    log_prefix=""
fi

dir_suffix=""
if [ -n "$covar_prefix" ] && [ -n "$pca_prefix" ]; then
    dir_suffix="${covar_prefix}_${pca_prefix}"
elif [ -n "$covar_prefix" ]; then
    dir_suffix="$covar_prefix"
elif [ -n "$pca_prefix" ]; then
    dir_suffix="$pca_prefix"
fi

if [ -n "$dir_suffix" ]; then
    intermediate_dir="$INTERMEDIATE_DIR/${log_prefix}cut_${trm_cutoff}_$dir_suffix"
    results_dir="$RESULTS_DIR/${log_prefix}cut_${trm_cutoff}_$dir_suffix"
else
    intermediate_dir="$INTERMEDIATE_DIR/${log_prefix}cut_$trm_cutoff"
    results_dir="$RESULTS_DIR/${log_prefix}cut_${trm_cutoff}"
fi

covars_dir="$intermediate_dir/covars"

mkdir -p "$covars_dir"
mkdir -p "$intermediate_dir"
mkdir -p "$results_dir"

oreml_pheno_data="$results_dir/oreml_pheno_data_${trm_cutoff}.phen"
pca_data="$intermediate_dir/pca_${trm_cutoff}"
excl_iids="$intermediate_dir/excl_iids_trm_${trm_cutoff}.list"
qc_bod="$intermediate_dir/qc_befile_${trm_cutoff}"
std_bod="$intermediate_dir/std_befile_${trm_cutoff}"
final_befile="$results_dir/final_befile"
final_befile_tmp="$intermediate_dir/final_befile_tmp"
qcovar_file="$results_dir/qcovar.qcovar"
covar_file="$results_dir/covar.covar"


# folder hierarchy scratch intermediate/cut/covars folders inside: pheno, trm, bod ?

# folder hierarchy scratch results/cut/covars (name)/n_pca folders inside: pheno, trm, oreml (.rsq files)


if [[ "$pc1" = true ]]; then
    echo -e "\n--pc1=true ...\n"

    echo -e "\nMaking efile ...\n"
    osca \
        --befile "$initial_befile" \
        --make-efile \
        --out "$initial_befile.txt"

    echo -e "\nRunning filter_pca1.R ...\n"
    Rscript \
        "$R_SCRIPTS_DIR/tblup/utils/filter_pca1.R" \
        --input "$initial_befile.txt" \
        --thresh -150 \
        > "$intermediate_dir/pca1_excl_iids.list"

    echo -e "\nFiltering BOD by PC1"
    osca \
        --befile "$initial_befile" \
        --remove "$intermediate_dir/pca1_excl_iids.list" \
        --make-bod \
        --out "$initial_befile.tmp"
    "$SH_UTILS_DIR/fix_opi.sh" \
        --opi "$initial_befile.tmp.opi"
    
    echo -e "\n$initial_befile <- $initial_befile.tmp"
    initial_befile="$initial_befile.tmp"
fi

echo -e "\nRunning bod_qc.sh ...\n"
if [ "$qc" = true ] && [ "$log2_transform" = true ]; then
    "$SH_PIPE_DIR/bod_qc.sh" \
        --befile "$initial_befile" \
        --qc \
        --log2-transform \
        --sd-min "$sd_min" \
        --missing-ratio-probe "$missing_ratio_probe" \
        --out-bod "$qc_bod"
elif [ "$qc" = true ]; then
    "$SH_PIPE_DIR/bod_qc.sh" \
        --befile "$initial_befile" \
        --qc \
        --sd-min "$sd_min" \
        --missing-ratio-probe "$missing_ratio_probe" \
        --out-bod "$qc_bod"
elif [ "$log2_transform" = true ]; then
    "$SH_PIPE_DIR/bod_qc.sh" \
        --befile "$initial_befile" \
        --log2-transform \
        --sd-min "$sd_min" \
        --missing-ratio-probe "$missing_ratio_probe" \
        --out-bod "$qc_bod"
else
    "$SH_PIPE_DIR/bod_qc.sh" \
        --befile "$initial_befile" \
        --out-bod "$qc_bod"
fi
echo -e "\nFinish bod_qc.sh\n"

echo -e "\nRunning std_bod.sh ...\n"
"$SH_UTILS_DIR/std_bod.sh" \
    --befile "$qc_bod" \
    --out-bod "$std_bod"
"$SH_UTILS_DIR/fix_opi.sh" \
    --opi "$std_bod.opi"
echo -e "\nFinish std_bod.sh\n"

# WORKS. #    --orm-cutoff "$trm_cutoff" add if does not work
--befile "$std_bod" \
    --make-orm \
    --out "$intermediate_dir/trm_900_${trm_cutoff}_tmp"
if [ "$trm_cutoff" = "nocut" ]; then
    osca \
        --orm "$intermediate_dir/trm_900_${trm_cutoff}_tmp" \
        --make-orm \
        --out "$intermediate_dir/trm_900_${trm_cutoff}"
else
    osca \
        --orm "$intermediate_dir/trm_900_${trm_cutoff}_tmp" \
        --orm-cutoff "$trm_cutoff" \
        --make-orm \
        --out "$intermediate_dir/trm_900_${trm_cutoff}"
fi

cp "$intermediate_dir/trm_900_${trm_cutoff}.orm.id" "$intermediate_dir/trm_900_${trm_cutoff}.list"
osca \
    --befile "$std_bod" \
    --keep "$intermediate_dir/trm_900_${trm_cutoff}.list" \
    --make-bod \
    --out "$final_befile_tmp"
"$SH_UTILS_DIR/fix_opi.sh" \
    --opi "$final_befile_tmp.opi"
rm "$intermediate_dir/trm_900_${trm_cutoff}.list"

if [[ "$iqr" = true ]]; then
    "$SH_PIPE_DIR/filter_trm_outliers.sh" \
        --befile "$final_befile_tmp" \
        --trm "$intermediate_dir/trm_900_${trm_cutoff}" \
        --out-bod "$final_befile" \
        --excl-iids "$excl_iids"
else
    cp "$final_befile_tmp.bod" "$final_befile.bod"
    cp "$final_befile_tmp.opi" "$final_befile.opi"
    cp "$final_befile_tmp.oii" "$final_befile.oii"
fi


if [ "${#covars[@]}" -gt 0 ]; then
    echo -e "\nRunning get_covars.sh ...\n"
    covar_tmp="$covars_dir/tmp"
    for covar_idx in "${covars[@]}"; do
        if in_array "$covar_idx" "${quantitative_covar_indices[@]}"; then
            used_covar_file="$qcovar_file"
        elif in_array "$covar_idx" "${categorical_covar_indices[@]}"; then
            used_covar_file="$covar_file"
        else
            echo -e "\nError: no match in covar indices\n"
            exit 1
        fi
        "$SH_UTILS_DIR/get_covar.sh" \
            --pheno-file "$initial_pheno" \
            --iid-idx 1 \
            --covar-idx "$covar_idx" \
            --oii "$final_befile.oii" \
            --out "$covar_tmp"
        
        covar_keep_iids="$intermediate_dir/covar_keep.list"
        gawk '{ print $1, $2 }' "$covar_tmp" > "$covar_keep_iids"

        if [ ! -s "$used_covar_file" ]; then
            cp "$covar_tmp" "$used_covar_file"
        else
            gawk '
                FNR==NR {a[$1]=$NF; next}
                ($1 in a) {print $0, a[$1]}
            ' "$covar_tmp" "$used_covar_file" > "$used_covar_file.tmp"
            mv "$used_covar_file.tmp" "$used_covar_file"
        fi

        osca \
            --befile "$final_befile" \
            --keep "$covar_keep_iids" \
            --make-bod \
            --out "$final_befile_tmp"

        "$SH_UTILS_DIR/fix_opi.sh" \
            --opi "$final_befile_tmp.opi"

        cp "$final_befile_tmp.bod" "$final_befile.bod"
        cp "$final_befile_tmp.opi" "$final_befile.opi"
        cp "$final_befile_tmp.oii" "$final_befile.oii"
    done 
fi

# Final TRM
"$SH_UTILS_DIR/fix_opi.sh" \
    --opi "$final_befile.opi"

if [ "$trm_cutoff" = "nocut" ]; then
    osca \
        --befile "$final_befile" \
        --make-orm \
        --out "$results_dir/trm"
else
    osca \
        --befile "$final_befile" \
        --make-orm \
        --orm-cutoff "$trm_cutoff" \
        --out "$results_dir/trm"
fi

"$SH_UTILS_DIR/get_oreml_pheno.sh" \
    --oii "$final_befile.oii" \
    --pheno-iid "$initial_pheno" \
    --out-pheno "$oreml_pheno_data"

if [ -n "$n_pca" ]; then
    "$SH_UTILS_DIR/get_pca.sh" \
        --trm "$results_dir/trm" \
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

if [ -s "$covar_file" ] && [ ! -s "$qcovar_file" ]; then
    "$SH_UTILS_DIR/run_oreml.sh" \
    --trm "$results_dir/trm" \
    --covar-file "$covar_file" \
    --pheno "$oreml_pheno_data" \
    --out "$results_dir/sol"
elif [ ! -s "$covar_file" ] && [ -s "$qcovar_file" ]; then
    "$SH_UTILS_DIR/run_oreml.sh" \
    --trm "$results_dir/trm" \
    --qcovar-file "$qcovar_file" \
    --pheno "$oreml_pheno_data" \
    --out "$results_dir/sol"
elif [ -s "$covar_file" ] && [ -s "$qcovar_file" ]; then
    "$SH_UTILS_DIR/run_oreml.sh" \
    --trm "$results_dir/trm" \
    --covar-file "$covar_file" \
    --qcovar-file "$qcovar_file" \
    --pheno "$oreml_pheno_data" \
    --out "$results_dir/sol"
elif [ ! -s "$covar_file" ] && [ ! -s "$qcovar_file" ]; then
    "$SH_UTILS_DIR/run_oreml.sh" \
    --trm "$results_dir/trm" \
    --out "$results_dir/sol" \
    --pheno "$oreml_pheno_data"
fi
