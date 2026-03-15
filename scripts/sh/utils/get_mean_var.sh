#!/bin/bash

source /home/s4693165/honours/config/paths.conf
source "$OSCA_CONF"

module load "$OSCA_MODULE"

mkdir -p "$PROBES_DIR"

out="$PROBES_DIR/probe"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --befile)
            befile="$2"
            shift 2
            ;;
        --out)
            out="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

osca \
    --befile "$befile" \
    --get-variance \
    --get-mean \
    --out "$out"
