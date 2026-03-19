'
FNR==NR {
    iid[$1]
    next
}
FNR==1 { next }
($1 in iid) {
    print $1, $1, $8
}
'