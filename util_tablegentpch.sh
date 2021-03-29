#!/bin/bash

function timedate() {
    TZ="America/Los_Angeles" date
    echo ""
}

function usageExit() {
    echo "Usage: sh util_tablegentpch.sh SCALE FORMAT"
    echo "SCALE must be greater than 1"
    echo "FORMAT must be either 'orc' | 'parquet'"
    exit 1
}

function runcommand() {
    if [[ "X$DEBUG_SCRIPT" != "X" ]]; then
        $1
        RETURN_VAL=$?
    else
        $1 2>/dev/null
        RETURN_VAL=$?
    fi
    
    if [[ "$RETURN_VAL" == "0" ]]; then
        echo "SUCCESS"
    else
        echo "FAILURE"
    fi
}

function generate_data() {
    echo "Start data generation for scale ${SCALE}"
    timedate

    hdfs dfs -mkdir -p "${DIR}"
    hdfs dfs -ls "${DIR}/${SCALE}" > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Generating data at scale factor $SCALE"
        (cd tpch-gen; hadoop jar target/*.jar -d "${DIR}/${SCALE}/" -s "${SCALE}")
    fi
    hdfs dfs -ls "${DIR}/${SCALE}" > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Data generation failed, exiting"
        exit 1
    fi
    hdfs dfs -chmod -R 777 "${DIR}/${SCALE}"

    echo "Finish text data generation complete"
    timedate
}

function create_text_tables() {
    echo "Start text table creation"
    timedate
    runcommand "$BEELINEURL -i settings/load-flat.sql -f ddl-tpch/bin_flat/alltables.sql --hivevar DB=${TEXT_DB} --hivevar LOCATION=${DIR}/${SCALE}"
    echo "Finish text table creation"
    timedate
}

function create_managed_tables() {
    echo "Start ${FORMAT} table creation at scale ${SCALE}"
    timedate

    i=1
    total=8
    MAX_REDUCERS=2500 # maximum number of useful reducers for any scale 
    if [[ $SCALE -gt $MAX_REDUCERS ]]; then
        REDUCERS=$MAX_REDUCERS
    else
        REDUCERS=$SCALE
    fi

    TABLES='part partsupp supplier customer orders lineitem nation region'
    for t in ${TABLES}; do
        echo "Optimizing table $t ($i/$total)."
        COMMAND="$BEELINEURL -i settings/load-partitioned.sql -f ddl-tpch/bin_partitioned/${t}.sql \ 
            --hivevar DB=${DATABASE} \
            --hivevar SCALE=${SCALE} \
            --hivevar SOURCE=${TEXT_DB} \
            --hivevar REDUCERS=${REDUCERS} \
            --hivevar FILE=${FORMAT}"
        runcommand "$COMMAND"
        i=$((i + 1))
    done

    echo "Finish ${FORMAT} table creation"
    timedate
}

# function load_constraints() {
#     echo "Start loading constraints"
#     timedate
#     runcommand "$BEELINEURL -f ddl-tpcds/bin_partitioned/add_constraints.sql --hivevar DB=${DATABASE}"
#     echo "Data loaded into database ${DATABASE}."
#     timedate
# }

function analyze_tables() {
    echo "Start analysis"
    timedate
    runcommand "$BEELINEURL -i settings/load-partitioned.sql -f ddl-tpch/bin_partitioned/analyze.sql --hivevar DB=${DATABASE}"
    echo "Finish analysis"
    timedate
}

# --- SCRIPT START ---

# DEBUG_SCRIPT="X"
SCALE=$1
FORMAT=$2
DIR=/tmp/tpch-generate

if [[ ! -f tpch-gen/target/tpch-gen-1.0-SNAPSHOT.jar ]]; then
    echo "Please build the data generator with ./tpch-build.sh first"
    exit 1
fi

if [[ "X$DEBUG_SCRIPT" != "X" ]]; then
    set -x
fi
if [[ "X$SCALE" == "X" || $SCALE -eq 1 ]]; then
    usageExit
fi
if [[ "$FORMAT" != "orc" && "$FORMAT" != "parquet" ]]; then
    usageExit
fi

HOSTNAME=$(hostname -f)
BEELINEURL="beeline -u 'jdbc:hive2://$HOSTNAME:10001/;transportMode=http'"
TEXT_DB="tpch_text_${SCALE}"
DATABASE="tpch_bin_partitioned_${FORMAT}_${SCALE}"

generate_data

create_text_tables

create_managed_tables

# load_constraints

analyze_tables
