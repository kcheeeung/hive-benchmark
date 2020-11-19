# Steps to use

## Prerequisites
- Hadoop 2.2 or later cluster or Sandbox.
- Apache Hive.
- Between 15 minutes and 2 days to generate data (depending on the Scale Factor you choose and available hardware).
- Have ```gcc``` in installed your system path. If your system does not have it, install it using yum or apt-get.

## Clone
```
git clone https://github.com/kcheeeung/hive-testbench.git && cd hive-testbench/
```

# Individual Steps

## 1. Build the benchmark
Build the benchmark you want to use (do all the prerequisites)

**TPC-DS**
```
./tpcds-build.sh
```
**TPC-H**
```
./tpch-build.sh
```

## 2. Generate the tables
Decide how much data you want. `SCALE` approximately is about # ~GB. Supported `FORMAT` includes: `orc` and `parquet`.

**Generic Usage**
```
nohup sh script.sh SCALE FORMAT
```
**TPC-DS**
```
nohup sh util_tablegentpcds.sh 10 orc
```
**TPC-H**
```
nohup sh util_tablegentpch.sh 10 orc
```

## 3. Run all the queries
- `SCALE` **must be the SAME size from an existing database!**
- Modify your settings in `settings.sql`.
- By default each query has a timeout it set to **2 hours!** Change in `util_internalRunQuery.sh` where `TIME_TO_TIMEOUT=120m`.
- Run the queries!

**TPC-DS Benchmark**
```
nohup sh util_runtpcds.sh 10 orc
```
**TPC-H Benchmark**
```
nohup sh util_runtpch.sh 10 orc
```

# Optional: Enable Performance Analysis Tool (PAT)
## 1. Connect Head to Worker Node 
```
sh util_connect.sh YOURPASSWORD
```

## 2. Enable PAT
Go into `util_runtpcds.sh` or `util_runtpch.sh`.
Switch the command by un/commenting. Example below.
```
# ./util_internalRunQuery.sh "$DATABASE" "$CURR_DIR$SETTINGS_PATH" "$CURR_DIR$query_path" "$CURR_DIR$LOG_PATH" "$i" "$CURR_DIR$REPORT_NAME.csv"

./util_internalGetPAT.sh /$CURR_DIR/util_internalRunQuery.sh "$DATABASE" "$CURR_DIR$SETTINGS_PATH" "$CURR_DIR$query_path" "$CURR_DIR$LOG_PATH" "$i" "$CURR_DIR$REPORT_NAME.csv" tpchPAT"$ID"/query"$i"/
```

# Optional: Run Queries using Different Connection 
Go into `util_internalRunQuery.sh`. Switch the command by uncommenting. Example below.
Add the appropriate information (`CLUSTERNAME` and `PASSWORD`).
```
# timeout $TIME_TO_TIMEOUT beeline -u "jdbc:hive2://`hostname -f`:10001/$INTERNAL_DATABASE;transportMode=http" -i $INTERNAL_SETTINGSPATH -f $INTERNAL_QUERYPATH &>> $INTERNAL_LOG_PATH

timeout $TIME_TO_TIMEOUT beeline -u "jdbc:hive2://CLUSTERNAME.azurehdinsight.net:443/$INTERNAL_DATABASE;ssl=true;transportMode=http;httpPath=/hive2" -n admin -p PASSWORD -i $INTERNAL_SETTINGSPATH -f $INTERNAL_QUERYPATH &>> $INTERNAL_LOG_PATH
```

# Troubleshooting

## Did my X step finish?
Check the `aaa_clock.txt` or `aab_clock.txt` file.
```
ps -ef | grep .sh
ps -ef | grep beeline
```

## Could not find database?
In the `settings.sql` file, add.
```
use DATABASENAME;
```

## How to debug
Uncomment the following line.
```
# DEBUG_SCRIPT=X
```
