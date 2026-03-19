{
    printf "%s %s", $1, $2
    for(i=1; i<=n; i++) {
        col = i + 2
        if(col <= NF)
            printf " %s", $col
    }
    printf "\n"
}