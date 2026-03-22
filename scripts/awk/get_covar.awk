FNR==NR {
    keep[$1]=1
    next
}
FNR==1 { next }
{
    iid = $iid_idx
    covar = $covar_idx
    if (covar != "NA" && covar != "" && iid in keep) {
        print iid, iid, covar
    }
}