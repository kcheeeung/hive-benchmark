#!/bin/bash

if [[ "$1" =~ ^[0-9]+$ && "$1" -gt "1" ]]; then
    DATABASE="tpch_orc_"$1
    beeline -u "jdbc:hive2://`hostname -f`:10001/$DATABASE;transportMode=http" -f droptable_tpch.hql
else
    echo "Invalid entry. Scale must also be greater than 1."
fi
