ARGIND == 1 {
    if (FNR == 1) next             
    barcode = $1
    iid = $2                        
    map[barcode] = iid
    next
}
ARGIND == 2 {
    if (FNR == 1) next              
    keep[$2] = 1                    
    next
}
ARGIND == 3 {
    if (FNR == 1) {                 
        $1 = "iid"
        print
        next
    }
    barcode = $1
    iid = map[barcode]
    if (iid in keep) {
        $1 = iid
        print
    }
}
