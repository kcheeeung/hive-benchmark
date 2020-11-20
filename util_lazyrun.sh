#!/bin/bash

if [[ "$2" =~ ^[0-9]+$ && "$2" -gt "1" ]]; then
    SCALE=$2

    chmod 777 *".sh"

    # Clock file
    rm aab_clock.txt
    echo "Start time" > aab_clock.txt
    TZ='America/Los_Angeles' date >> aab_clock.txt

    if [ "$1" == "tpch" ]; then
        ./tpch-build.sh
        echo "Finish tpch build" >> aab_clock.txt
        TZ='America/Los_Angeles' date >> aab_clock.txt

        ./util_tablegentpch.sh $SCALE
        echo "Finish tpch tablegen" >> aab_clock.txt
        TZ='America/Los_Angeles' date >> aab_clock.txt

        ./util_runtpch.sh $SCALE
        echo "Finish tpch run scale $SCALE" >> aab_clock.txt
        TZ='America/Los_Angeles' date >> aab_clock.txt

    elif [ "$1" == "tpcds" ]; then
        ./tpcds-build.sh
        echo "Finish tpcds build" >> aab_clock.txt
        TZ='America/Los_Angeles' date >> aab_clock.txt

        ./util_tablegentpcds.sh $SCALE
        echo "Finish tpcds tablegen" >> aab_clock.txt
        TZ='America/Los_Angeles' date >> aab_clock.txt

        ./util_runtpcds.sh $SCALE
        echo "Finish tpcds run scale $SCALE" >> aab_clock.txt
        TZ='America/Los_Angeles' date >> aab_clock.txt

    else
        echo "Invalid benchmark"
        exit 1
    fi
else
    echo "Invalid scale"
    exit 1
fi
