FNR==NR {
    iid[$1] = $2
    next
}

FNR==1 { next }

$phenoIdx == "NA" {
    if ($1 in iid)
        print iid[$1], iid[$1]
}