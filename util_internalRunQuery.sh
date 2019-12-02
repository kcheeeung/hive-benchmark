#!/bin/bash

INTERNAL_DATABASE=$1
INTERNAL_SETTINGSPATH=$2
INTERNAL_QUERYPATH=$3
INTERNAL_LOG_PATH=$4
INTERNAL_QID=$5
INTERNAL_CSV=$6

# Beeline command to execute
START_TIME="`date +%s`"
beeline -u "jdbc:hive2://`hostname`:10001/$INTERNAL_DATABASE;transportMode=http" -i $INTERNAL_SETTINGSPATH -f $INTERNAL_QUERYPATH &>> $INTERNAL_LOG_PATH
RETURN_VAL=$?
END_TIME="`date +%s`"

if [[ $RETURN_VAL = 0 ]]; then
    status="SUCCESS"
else
    status="FAIL"
fi

# calculate time
secs_elapsed="$(($END_TIME - $START_TIME))"
# record data
echo $INTERNAL_QID, $secs_elapsed, $status >> $INTERNAL_CSV
# report status to terminal
echo "query$INTERNAL_QID: $status"
