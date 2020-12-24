#!/bin/bash

function timedate() {
    TZ="America/Los_Angeles" date
    echo ""
}

function usageExit() {
    echo "Usage: sh util_tablegentpcds.sh SCALE FORMAT"
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

    hdfs dfs -mkdir -p ${DIR}
    hdfs dfs -ls ${DIR}/${SCALE} > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Generating data at scale factor $SCALE"
        (cd tpcds-gen; hadoop jar target/*.jar -d ${DIR}/${SCALE}/ -s ${SCALE})
    fi
    hdfs dfs -ls ${DIR}/${SCALE} > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Data generation failed, exiting"
        exit 1
    fi
    hdfs dfs -chmod -R 777  ${DIR}/${SCALE}

    echo "Finish text data generation complete"
    timedate
}

function create_text_tables() {
    echo "Start text table creation"
    timedate
    runcommand "$BEELINEURL -i settings/load-flat.sql -f ddl-tpcds/text/alltables.sql --hivevar DB=${TEXT_DB} --hivevar LOCATION=${DIR}/${SCALE}"
    echo "Finish text table creation"
    timedate
}

function create_managed_tables() {
    echo "Start ${FORMAT} table creation at scale ${SCALE}"
    timedate

    LOAD_FILE="load_${FORMAT}_${SCALE}.mk"
    SILENCE="2> /dev/null 1> /dev/null" 
    if [ "X$DEBUG_SCRIPT" != "X" ]; then
        SILENCE=""
    fi

    DIMS="date_dim time_dim item customer customer_demographics household_demographics customer_address store promotion warehouse ship_mode reason income_band call_center web_page catalog_page web_site"
    FACTS="store_sales store_returns web_sales web_returns catalog_sales catalog_returns inventory"
    echo -e "all: ${DIMS} ${FACTS}" > $LOAD_FILE

    i=1
    total=24
    MAX_REDUCERS=2500 # maximum number of useful reducers for any scale 
    REDUCERS=$((test ${SCALE} -gt ${MAX_REDUCERS} && echo ${MAX_REDUCERS}) || echo ${SCALE})

    # Populate the smaller tables.
    for t in ${DIMS}; do
        COMMAND="$BEELINEURL -i settings/load-partitioned.sql -f ddl-tpcds/bin_partitioned/${t}.sql \
            --hivevar DB=${DATABASE} \
            --hivevar SCALE=${SCALE} \
            --hivevar SOURCE=${TEXT_DB} \
            --hivevar REDUCERS=${REDUCERS} \
            --hivevar FILE=${FORMAT}"
        echo -e "${t}:\n\t@$COMMAND $SILENCE && echo 'Optimizing table $t ($i/$total).'" >> $LOAD_FILE
        i=`expr $i + 1`
    done

    for t in ${FACTS}; do
        COMMAND="$BEELINEURL -i settings/load-partitioned.sql -f ddl-tpcds/bin_partitioned/${t}.sql \
            --hivevar DB=${DATABASE} \
            --hivevar SCALE=${SCALE} \
            --hivevar SOURCE=${TEXT_DB} \
            --hivevar REDUCERS=${REDUCERS} \
            --hivevar FILE=${FORMAT}"
        echo -e "${t}:\n\t@$COMMAND $SILENCE && echo 'Optimizing table $t ($i/$total).'" >> $LOAD_FILE
        i=`expr $i + 1`
    done

    make -j 1 -f $LOAD_FILE

    echo "Finish ${FORMAT} table creation"
    timedate
}

function load_constraints() {
    echo "Start loading constraints"
    timedate
    runcommand "$BEELINEURL -f ddl-tpcds/bin_partitioned/add_constraints.sql --hivevar DB=${DATABASE}"
    echo "Data loaded into database ${DATABASE}."
    timedate
}

function analyze_tables() {
    echo "Start analysis"
    timedate
    runcommand "$BEELINEURL -f ddl-tpcds/bin_partitioned/analyze.sql --hivevar DB=${DATABASE}"
    echo "Finish analysis"
    timedate
}

# --- SCRIPT START ---

# DEBUG_SCRIPT="X"
SCALE=$1
FORMAT=$2
DIR=/tmp/tpcds-generate

if [[ ! -f tpcds-gen/target/tpcds-gen-1.0-SNAPSHOT.jar ]]; then
    echo "Please build the data generator with ./tpcds-build.sh first"
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

HOSTNAME=`hostname -f`
BEELINEURL="beeline -u 'jdbc:hive2://$HOSTNAME:10001/;transportMode=http'"
TEXT_DB="tpcds_text_${SCALE}"
DATABASE="tpcds_bin_partitioned_${FORMAT}_${SCALE}"

generate_data

create_text_tables

create_managed_tables

load_constraints

analyze_tables
