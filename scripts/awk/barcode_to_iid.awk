BEGIN { OFS="\t" }

# Read the map (first file)
NR==FNR {
    if (FNR==1) next   # skip header of pheno_map
    map[$1] = $2
    next
}

# Process pheno_file (second file)
FNR==1 { print; next }  # keep header

{
    if ($1 in map) $1 = map[$1]
    print
}