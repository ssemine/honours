#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$PHENO_CONF"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --initial-bfile)
            initial_bfile="$2"
            shift 2
            ;;
        --auto-bfile)
            auto_bfile="$2"
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
        --shared-bfile)
            shared_bfile="$2"
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
        --no-na-bfile)
            no_na_bfile="$2"
            shift 2
            ;;
        --afc-900-bfile)
            afc_900_bfile="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

excl_iids_not_shared="$EXCL_IIDS_FGBBLUP1"
excl_iids2="$EXCL_IIDS_FGBBLUP2"
excl_iids3="$EXCL_IIDS_FGBBLUP3"



# Temp disabled, no sex chr in the analysis
# Filters BOD for sex chromosomes
#echo "Running exclude_sex_chr.sh ..."
#"$SH_UTILS_DIR/exclude_sex_chr.sh" \
#    --bfile "$initial_bfile" \
#    --opi "$initial_bfile.opi" \
#    --out-gene-list "$auto_gene_list" \
#    --out-bod "$auto_bfile"

# Filters BOD and phenotype files by excluding non-shared individuals 
echo "Running filter_bod_pheno.sh ..."
"$SH_GBLUP_UTILS_DIR/filter_bed_pheno.sh" \
    --pheno-map "$pheno_map" \
    --pheno-file "$pheno_file" \
    --bfile "$auto_bfile" \
    --excl-iids "$excl_iids_not_shared" \
    --fam "$auto_bfile.fam" \
    --out-bed "$shared_bfile" \
    --out-pheno "$shared_pheno" &&

# Filters BOD and phenotype files for NA values, specifically AFC
"$SH_TBLUP_UTILS_DIR/barcode_to_iid.sh" \
    --pheno-file "$shared_pheno" \
    --pheno-map "$pheno_map" \
    --out "$iid_pheno" &&

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
' "$iid_pheno" > "$iid_pheno.tmp" &&
mv "$iid_pheno.tmp" "$iid_pheno" &&

"$SH_GBLUP_UTILS_DIR/filter_iid_na.sh" \
    --bfile "$shared_bfile" \
    --out-bed "$no_na_bfile" \
    --excl-iids "$excl_iids2" &&

# Filters for AFC < 900
"$SH_GBLUP_UTILS_DIR/filter_pheno_900.sh" \
    --bfile "$no_na_bfile" \
    --out-bed "$afc_900_bfile" \
    --excl-iids "$excl_iids3"
