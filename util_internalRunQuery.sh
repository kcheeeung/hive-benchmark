#!/bin/bash

INTERNAL_DATABASE=$1
INTERNAL_SETTINGSPATH=$2
INTERNAL_QUERYPATH=$3
INTERNAL_LOG_PATH=$4
INTERNAL_QID=$5
INTERNAL_CSV=$6

TIME_TO_TIMEOUT=120m

# Beeline command to execute
START_TIME="`date +%s`"
timeout $TIME_TO_TIMEOUT beeline -u "jdbc:hive2://`hostname -f`:10001/$INTERNAL_DATABASE;transportMode=http" -i $INTERNAL_SETTINGSPATH -f $INTERNAL_QUERYPATH &>> $INTERNAL_LOG_PATH

# timeout $TIME_TO_TIMEOUT beeline -u "jdbc:hive2://CLUSTERNAME.azurehdinsight.net:443/$INTERNAL_DATABASE;ssl=true;transportMode=http;httpPath=/hive2" -n admin -p PASSWORD -i $INTERNAL_SETTINGSPATH -f $INTERNAL_QUERYPATH &>> $INTERNAL_LOG_PATH

RETURN_VAL=$?
END_TIME="`date +%s`"

if [[ $RETURN_VAL == 0 ]]; then
    secs_elapsed="$(($END_TIME - $START_TIME))"
    echo $INTERNAL_QID, $secs_elapsed, "SUCCESS" >> $INTERNAL_CSV
    echo "query$INTERNAL_QID: SUCCESS"
else
    echo $INTERNAL_QID, " ", "FAILURE" >> $INTERNAL_CSV
    echo "query$INTERNAL_QID: FAILURE"
    echo "Status code was: $RETURN_VAL"
fi

# Misc recovery for system
sleep 5
