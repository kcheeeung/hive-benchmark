#!/bin/bash

function timedate() {
    TZ="America/Los_Angeles" date
}

function installLibs() {
    # Install maven
    which mvn
    if [[ $? -ne 0 ]]; then
        echo "Installing maven"
        sudo apt install maven -y
    else
        echo "Maven already installed"
    fi
}

function buildGenerator() {
    echo "Building TPC-DS Data Generator"
    (cd tpcds_resources; make)
    echo "TPC-DS Data Generator built."
}

function generateData() {
    hdfs dfs -rm -R /HiveTPCDS_$INPUT_SCALE
    echo "Generating data at scale factor $INPUT_SCALE."
    (cd tpcds_resources; hadoop jar target/*.jar -d /HiveTPCDS_$INPUT_SCALE -s $INPUT_SCALE)

    hdfs dfs -ls /HiveTPCDS_$INPUT_SCALE/ > /dev/null
    if [ $? -ne 0 ]; then
        echo "Data generation failed, exiting."
        exit 1
    fi
}

if [[ "$#" -ne 2 ]]; then
    echo "Incorrect number of arguments."
    echo "Usage is as follows:"
    echo "sh util_tablgentpcds.sh SCALE FORMAT"
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

    # scale ~GB
    INPUT_SCALE="$1"
    # Name of clock file
    CLOCK_FILE="aaa_clocktime.txt"
    # Clock file
    rm $CLOCK_FILE
    echo "Old clock removed"
    echo "Created new clock"
    echo "Table gen time for TPC-DS $INPUT_SCALE" > $CLOCK_FILE
    timedate >> $CLOCK_FILE
    echo "" >> $CLOCK_FILE

    installLibs
    buildGenerator

    # data generation
    echo "Start data generation" >> $CLOCK_FILE
    timedate >> $CLOCK_FILE
    generateData
    echo "End" >> $CLOCK_FILE
    timedate >> $CLOCK_FILE
    echo "" >> $CLOCK_FILE

    MAX_REDUCERS=2600 # ~7 years of data hortonworks
    REDUCERS=$((test ${INPUT_SCALE} -gt ${MAX_REDUCERS} && echo ${MAX_REDUCERS}) || echo ${INPUT_SCALE})

    # external table creation
    echo "Start table generation" >> $CLOCK_FILE
    timedate >> $CLOCK_FILE
    beeline -u "jdbc:hive2://`hostname -f`:10001/;transportMode=http" -i settingsTable.hql -f tpcds_dll/createAllExternalTables.hql --hiveconf LOCATION=/HiveTPCDS_$INPUT_SCALE/ --hiveconf DBNAME=tpcds_$INPUT_SCALE --hiveconf REDUCERS=$REDUCERS
    echo "End" >> $CLOCK_FILE
    timedate >> $CLOCK_FILE
    echo "" >> $CLOCK_FILE

    if [[ "$2" == "orc" ]]; then
        # orc tables
        echo "Start orc table generation" >> $CLOCK_FILE
        timedate >> $CLOCK_FILE
        beeline -u "jdbc:hive2://`hostname -f`:10001/;transportMode=http" -i settingsTable.hql -f tpcds_dll/createAllORCTables.hql --hiveconf ORCDBNAME=tpcds_orc_$INPUT_SCALE --hiveconf SOURCE=tpcds_$INPUT_SCALE --hiveconf REDUCERS=$REDUCERS
        echo "End" >> $CLOCK_FILE
        timedate >> $CLOCK_FILE
        echo "" >> $CLOCK_FILE

        echo "Start orc analysis" >> $CLOCK_FILE
        timedate >> $CLOCK_FILE
        beeline -u "jdbc:hive2://`hostname -f`:10001/;transportMode=http" -i settings.hql -f tpcds_dll/analyze.hql --hiveconf DB=tpcds_orc_$INPUT_SCALE
        echo "End" >> $CLOCK_FILE
        timedate >> $CLOCK_FILE
        echo "" >> $CLOCK_FILE
    else
        # parquet tables
        echo "Start parquet table generation" >> $CLOCK_FILE
        timedate >> $CLOCK_FILE
        beeline -u "jdbc:hive2://`hostname -f`:10001/;transportMode=http" -i settingsTable.hql -f tpcds_dll/createAllParquetTables.hql --hiveconf PARQUETDBNAME=tpcds_parquet_$INPUT_SCALE --hiveconf SOURCE=tpcds_$INPUT_SCALE --hiveconf REDUCERS=$REDUCERS
        echo "End" >> $CLOCK_FILE
        timedate >> $CLOCK_FILE
        echo "" >> $CLOCK_FILE

        echo "Start parquet analysis" >> $CLOCK_FILE
        timedate >> $CLOCK_FILE
        beeline -u "jdbc:hive2://`hostname -f`:10001/;transportMode=http" -i settings.hql -f tpcds_dll/analyze.hql --hiveconf DB=tpcds_parquet_$INPUT_SCALE
        echo "End" >> $CLOCK_FILE
        timedate >> $CLOCK_FILE
        echo "" >> $CLOCK_FILE
    fi

    echo "End time" >> $CLOCK_FILE
    timedate >> $CLOCK_FILE
else
    echo "Scale must be greater than 1."
fi
