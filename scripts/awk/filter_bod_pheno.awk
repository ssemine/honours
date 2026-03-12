BEGIN {
    missing_count = 0
}
ARGIND==1 {
    needed_iid[$2] = 1
    iid_order[++iid_index] = $2
    all_iids[$2] = 1
    next
}
ARGIND==2 {
    if (FNR==1) next
    if ($2 in needed_iid) {
        iid_to_barcode[$2] = $1
        barcode_keep[$1] = $2
    }
    next
}
ARGIND==3 {
    if (FNR==1) {
        print > out_pheno
        next
    }

    if ($1 in barcode_keep) {
        print > out_pheno
        delete all_iids[barcode_keep[$1]]
    }
}
END {
    for (i=1; i<=iid_index; i++) {
        iid = iid_order[i]
        if (iid in all_iids) {
            print iid, iid > out_missing
            missing_count++
        }
    }
}
