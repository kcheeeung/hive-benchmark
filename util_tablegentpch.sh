#!/bin/bash

if [[ "$1" =~ ^[0-9]+$ && "$1" -gt "1" ]]; then
    # scale ~GB
    INPUT_SCALE="$1"
    # Name of clock file
    CLOCK_FILE="aaa_clocktime.txt"
    # Clock file
    rm $CLOCK_FILE
    echo "Old clock removed"
    echo "Created new clock"
    echo "Table gen time for TPC-H "$SCALE > $CLOCK_FILE

    echo "Start time" >> $CLOCK_FILE
    TZ='America/Los_Angeles' date >> $CLOCK_FILE

    # data generation
    hdfs dfs -copyFromLocal resources /tmp
    beeline -u "jdbc:hive2://`hostname -f`:10001/;transportMode=http" -n "" -p "" -i settingsData.hql -f TPCHDataGen.hql -hiveconf SCALE=$INPUT_SCALE -hiveconf PARTS=$INPUT_SCALE -hiveconf LOCATION=/HiveTPCH_$INPUT_SCALE/ -hiveconf TPCHBIN=`grep -A 1 "fs.defaultFS" /etc/hadoop/conf/core-site.xml | grep -o "wasb[^<]*"`/tmp/resources

    # table creation
    hdfs dfs -mkdir -p /HiveTPCH_$INPUT_SCALE/
    hadoop fs -chmod -R 777 /HiveTPCH_$INPUT_SCALE/
    beeline -u "jdbc:hive2://`hostname -f`:10001/;transportMode=http" -n "" -p "" -i settings.hql -f tpch_ddl/createAllExternalTables.hql -hiveconf LOCATION=/HiveTPCH_$INPUT_SCALE/ -hiveconf DBNAME=tpch_$INPUT_SCALE

    # orc tables
    beeline -u "jdbc:hive2://`hostname -f`:10001/;transportMode=http" -n "" -p "" -i settings.hql -f tpch_ddl/createAllORCTables.hql -hiveconf ORCDBNAME=tpch_orc_$INPUT_SCALE -hiveconf SOURCE=tpch_$INPUT_SCALE

    echo "End time" >> $CLOCK_FILE
    TZ='America/Los_Angeles' date >> $CLOCK_FILE
else
    echo "Invalid entry. Scale must also be greater than 1."
fi
