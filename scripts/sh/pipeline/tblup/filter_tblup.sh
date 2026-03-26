#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --initial-befile)
            initial_befile="$2"
            shift 2
            ;;
        --auto-gene-list)
            auto_gene_list="$2"
            shift 2
            ;;
        --auto-befile)
            auto_befile="$2"
            shift 2
            ;;
        --pheno-map)
            pheno_map="$2"
            shift 2
            ;;
        --pheno)
            pheno_file="$2"
            shift 2
            ;;
        --excl-iids-not-shared)
            excl_iids_not_shared="$2"
            shift 2
            ;;
        --shared-befile)
            shared_befile="$2"
            shift 2
            ;;
        --shared-pheno)
            shared_pheno="$2"
            shift 2
            ;;
        --iid-pheno)
            iid_pheno="$2"
            shift 2
            ;;
        --no-na-befile)
            no_na_befile="$2"
            shift 2
            ;;
        --afc-900-befile)
            afc_900_befile="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done


# Temp disabled, no sex chr in the analysis
# Filters BOD for sex chromosomes
#echo "Running exclude_sex_chr.sh ..."
#"$SH_UTILS_DIR/exclude_sex_chr.sh" \
#    --befile "$initial_befile" \
#    --opi "$initial_befile.opi" \
#    --out-gene-list "$auto_gene_list" \
#    --out-bod "$auto_befile"

# Filters BOD and phenotype files by excluding non-shared individuals 
echo "Running filter_bod_pheno.sh ..."
"$SH_TBLUP_UTILS_DIR/filter_bod_pheno.sh" \
    --pheno-map "$pheno_map" \
    --pheno-file "$pheno_file" \
    --befile "$auto_befile" \
    --excl-iids "$excl_iids_not_shared" \
    --oii "$auto_befile.oii" \
    --out-bod "$shared_befile" \
    --out-pheno "$shared_pheno"

"$SH_TBLUP_UTILS_DIR/fix_opi.sh" \
    --opi "$shared_befile.opi" 

# Filters BOD and phenotype files for NA values, specifically AFC
"$SH_TBLUP_UTILS_DIR/barcode_to_iid.sh" \
    --pheno-file "$shared_pheno" \
    --pheno-map "$pheno_map" \
    --out "$iid_pheno"

# adds columns add for stages
gawk '
    BEGIN {OFS="\t"}             
    NR==1 {                       
        print $0, "hef_wks_preg_bin"
        next
    }
    {
        if ($7 ~ /^[0-9]+$/) {    
            bin = ($7 == 0) ? 0 : 1
        } else {                       
            bin = "NA"
        }
        print $0, bin
    }
' "$iid_pheno" > "$iid_pheno.tmp"
mv "$iid_pheno.tmp" "$iid_pheno"

# Checks for NA values
"$SH_TBLUP_UTILS_DIR/filter_iid_na.sh" \
    --befile "$shared_befile" \
    --out-bod "$no_na_befile"

"$SH_TBLUP_UTILS_DIR/fix_opi.sh" \
    --opi "$no_na_befile.opi" 

# Filters for AFC < 900
"$SH_TBLUP_UTILS_DIR/filter_pheno_900.sh" \
    --befile "$no_na_befile" \
    --out-bod "$afc_900_befile"

"$SH_TBLUP_UTILS_DIR/fix_opi.sh" \
    --opi "$afc_900_befile.opi" 
