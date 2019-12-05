#!/bin/bash

if [[ "$1" =~ ^[0-9]+$ && "$1" -gt "1" ]]; then
    if [[ "$2" == "orc" || "$2" == "parquet" ]]; then
        echo "File format ok"
    else
        echo "Invalid file format"
        exit 1
    fi

    # Database
    if [[ "$2" == "orc" ]]; then
        DATABASE="tpch_orc_"$SCALE
    else
        DATABASE="tpch_parquet_"$SCALE
    fi
    # Command
    beeline -u "jdbc:hive2://`hostname -f`:10001/$DATABASE;transportMode=http" -f droptable_tpch.hql
else
    echo "Invalid entry. Scale must also be greater than 1."
fi
