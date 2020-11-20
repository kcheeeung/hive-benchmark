#!/bin/bash

# NOT MEANT TO BE RUN STAND ALONE
# Takes in:

cat <<EOM > PAT/PAT-collecting-data/config
ALL_NODES: `cat /etc/hadoop/conf/slaves | tr '\r\n' ' '`

WORKER_SCRIPT_DIR: /tmp/PAT
WORKER_TMP_DIR: /tmp/PAT_TMP
CMD_PATH: $1 $2 $3 $4 $5 $6 $7
SAMPLE_RATE: 1
INSTRUMENTS: cpustat memstat netstat iostat vmstat jvms perf
EOM

chmod +x PAT/PAT-collecting-data/config

cd PAT/PAT-collecting-data/
./pat run $8
cd ../../
