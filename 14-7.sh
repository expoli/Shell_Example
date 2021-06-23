#!/usr/bin/env bash

# echo "Please input the first number!"
set -x

function Greatest_common_divisor {
    if [[ $1 -gt $2 ]]; then
        big=$1
        small=$2
    else
        big=$2
        small=$1
    fi
    res=$small
    time=0
    while [ "$res" -gt 0 ]; do
        time=$((time + 1))
        res=$((big % small))
        big=$small
        small=$res
    done
    echo "the result is $big"
}

function Check_input {
    if [[ $# != 2 ]]; then
        echo "Please input two number! Example: ./14-7.sh 6 4"
        exit 1

    elif [[ ! $1 -gt 0 || ! $2 -gt 0 ]] 2>/dev/null; then
        echo "The numbers you input must bigger than zero!"
        exit 1
    else
        echo "the first number is $1"
        echo "the second number is $2"
        Greatest_common_divisor "$1" "$2"
    fi
}

Check_input "$1" "$2"
