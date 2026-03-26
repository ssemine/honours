#!/bin/bash

# Fixes OSCA's bug that assigns chr 23 and 24 X and Y values

while [[ $# -gt 0 ]]; do
    case "$1" in
        --opi)
            opi="$2"
            shift 2
            ;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
    esac
done

gawk '{
    if ($1 == "X" || $1 == "x") $1 = 23
    else if ($1 == "Y" || $1 == "y") $1 = 24
    print
}' "$opi" > "$opi.tmp" && mv "$opi.tmp" "$opi"