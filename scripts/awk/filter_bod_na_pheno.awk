BEGIN {
    FS="[ \t]+"
    OFS="\t"
}

FNR==NR {
    iid[$1]=$2
    fid[$1]=$3
    next
}

FNR==1 { next }

$phenoIdx=="NA" {
    if($1 in iid)
        print fid[$1], iid[$1]
}
