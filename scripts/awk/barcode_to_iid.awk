FNR==NR {
    map[$1] = $2
    next
}
FNR==1 {
    print  
    next
}

{
    if ($1 in map) {
        $1 = map[$1]
    }
    print
}