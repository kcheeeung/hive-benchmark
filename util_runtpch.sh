#!/bin/bash

function timedate() {
    TZ="America/Los_Angeles" date
}

ID=`TZ="America/Los_Angeles" date +"%m.%d.%Y-%H.%M.%S"`

if [[ "$#" -ne 2 ]]; then
    echo "Incorrect number of arguments."
    echo "Usage is as follows:"
    echo "sh util_runtpch.sh SCALE FORMAT"
    exit 1
fi

if [[ "$1" =~ ^[0-9]+$ && "$1" -gt "1" ]]; then
    if [[ "$2" == "orc" || "$2" == "parquet" ]]; then
        echo "File format ok"
    else
        echo "Invalid. Supported formats are:"
        echo "orc"
        echo "parquet"
        exit 1
    fi

    # query file name
    QUERY_BASE_NAME="tpch_queries/tpch_query"
    QUERY_FILE_EXT=".hql"
    # settings file location
    SETTINGS_PATH="settings.hql"

    # scale ~GB
    SCALE="$1"
    # report name
    REPORT_NAME="time_elapsed_tpch"
    # database name
    if [[ "$2" == "orc" ]]; then
        DATABASE="tpch_orc_"$SCALE
    else
        DATABASE="tpch_parquet_"$SCALE
    fi
    # hostname
    HOSTNAME=`hostname -f`
    # Clock file
    CLOCK_FILE="aaa_clocktime.txt"
    rm $CLOCK_FILE
    echo "Old clock removed"
    echo "Created new clock"
    echo "Run queries for TPC-H at scale $SCALE" > $CLOCK_FILE
    timedate >> $CLOCK_FILE

    # generate time report
    rm $REPORT_NAME*".csv"
    echo "Old report removed"
    echo "query #", "secs elapsed", "status" > $REPORT_NAME".csv"
    echo "New report generated"

    # remove old llapio_summary
    rm "llapio_summary"*".csv"
    echo "Old llapio_summary*.csv removed"

    # remove old time_precise_
    rm "time_precise_"*".csv"
    echo "Old time_precise_*.csv removed"
 
    # clear and make new log directory
    rm -r log_query/
    echo "Old logs removed"
    mkdir log_query/
    echo "Log folder generated"

    # make executable
    chmod +x *".sh"
    chmod -R +x PAT/

    # absolute path
    CURR_DIR="`pwd`/"

    # range of queries
    START=1
    END=22
    for (( i = $START; i <= $END; i++ )); do
        query_path=($QUERY_BASE_NAME$i$QUERY_FILE_EXT)
        LOG_PATH="log_query/logquery$i.txt"
    
        if [[ -f $query_path ]]; then
            ./util_internalRunQuery.sh "$DATABASE" "$CURR_DIR$SETTINGS_PATH" "$CURR_DIR$query_path" "$CURR_DIR$LOG_PATH" "$i" "$CURR_DIR$REPORT_NAME.csv"

            # See util_internalGetPAT
            # ./util_internalGetPAT.sh /$CURR_DIR/util_internalRunQuery.sh "$DATABASE" "$CURR_DIR$SETTINGS_PATH" "$CURR_DIR$query_path" "$CURR_DIR$LOG_PATH" "$i" "$CURR_DIR$REPORT_NAME.csv" tpchPAT"$ID"/query"$i"/
        else
            # report failure
            echo $i, " ", "FAILURE_FILENOTFOUND" >> "$CURR_DIR$REPORT_NAME.csv"
            echo "query$i: FAILURE"
        fi
    done

    # python3 parselog.py
    # python3 parse_precisetime.py tpch
    mv $REPORT_NAME".csv" $REPORT_NAME$ID".csv"
    zip -j log_query.zip log_query/*
    zip -r "tpch-"$SCALE"GB-"$ID".zip" log_query.zip PAT/PAT-collecting-data/results/tpchPAT"$ID"/* $REPORT_NAME$ID".csv" "llapio_summary"*".csv" "time_precise_tpch"*".csv"
    rm log_query.zip
    
    echo "End" >> $CLOCK_FILE
    timedate >> $CLOCK_FILE
else
    echo "Scale must be greater than 1."
fi
