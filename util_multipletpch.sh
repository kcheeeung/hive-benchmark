#!/bin/bash

if [[ "$#" -ne 3 ]]; then
    echo "Incorrect number of arguments."
    echo "Usage is as follows:"
    echo "sh util_runtpch.sh SCALE FORMAT ROUNDS"
    exit 1
fi

chmod +x *".sh"

for (( i = 0; i < $3; i++ )); do
    ./util_runtpch.sh $1 $2
done
