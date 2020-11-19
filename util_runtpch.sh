#!/bin/bash

# Run and time the benchmark without baby sitting the scripts
# Use: nohup


if [[ "$1" =~ ^[0-9]+$ && "$1" -gt "1" ]]; then
    # query file name
    QUERY_BASE_NAME="sample-queries-tpch/tpch_query"
    QUERY_FILE_EXT=".sql"
    # settings file location
    SETTINGS_PATH="settings.sql"


    # scale ~GB
    SCALE="$1"
    # report name
    REPORT_NAME="time_elapsed_tpch"
    # database name
    DATABASE="tpch_flat_orc_"$SCALE
    # hostname
    HOSTNAME=`hostname`
    # name of clock file
    CLOCK_FILE="aaa_clocktime.txt"


    if [[ -f $CLOCK_FILE ]]; then
        rm $CLOCK_FILE
        echo "Old clock removed"
    fi
    echo "Created new clock"
    echo "Run queries for TPC-H at scale "$SCALE > $CLOCK_FILE
    TZ='America/Los_Angeles' date >> $CLOCK_FILE

    # generate time report
    rm $REPORT_NAME*".csv"
    echo "Old report removed"
    echo "query #", "secs elapsed", "status" > $REPORT_NAME".csv"
    echo "New report generated"

    # remove old llapio_summary
    rm "llapio_summary"*".csv"
    echo "Old llapio_summary*.csv removed"

    # clear and make new log directory
    if [[ -d log_query/ ]]; then
        rm -r log_query/
        echo "Old logs removed"
    fi
    mkdir log_query/
    echo "Log folder generated"

    # make executable
    chmod +x util_internalGetPAT.sh
    chmod +x util_internalRunQuery.sh
    chmod -R +x PAT/

    # absolute path
    CURR_DIR="`pwd`/"

    ID=`TZ='America/Los_Angeles' date +"%m.%d.%Y-%H.%M.%S"`
    # range of queries
    START=1
    END=22
    for (( i = $START; i <= $END; i++ )); do
        query_path=($QUERY_BASE_NAME$i$QUERY_FILE_EXT)
        LOG_PATH="log_query/logquery$i.txt"
    
        ./util_internalRunQuery.sh "$DATABASE" "$CURR_DIR$SETTINGS_PATH" "$CURR_DIR$query_path" "$CURR_DIR$LOG_PATH" "$i" "$CURR_DIR$REPORT_NAME.csv"

        # ./util_internalGetPAT.sh /$CURR_DIR/util_internalRunQuery.sh "$DATABASE" "$CURR_DIR$SETTINGS_PATH" "$CURR_DIR$query_path" "$CURR_DIR$LOG_PATH" "$i" "$CURR_DIR$REPORT_NAME.csv" tpchPAT"$ID"/query"$i"/

    done

    echo "Finished" >> $CLOCK_FILE
    TZ='America/Los_Angeles' date >> $CLOCK_FILE

    python3 parselog.py
    mv $REPORT_NAME".csv" $REPORT_NAME$ID".csv"
    zip -j log_query.zip log_query/*
    zip -r "tpch-"$SCALE"GB-"$ID".zip" log_query.zip PAT/PAT-collecting-data/results/tpchPAT"$ID"/* $REPORT_NAME$ID".csv" "llapio_summary"*".csv"
    rm log_query.zip
else
    echo "Invalid entry. Scale must also be greater than 1."
fi
