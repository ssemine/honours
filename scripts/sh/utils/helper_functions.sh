#!/bin/bash

in_array() {
    local val="$1"; shift
    for x in "$@"; do
        if [[ "$x" == "$val" ]]; then
            return 0
        fi
    done
    return 1
}