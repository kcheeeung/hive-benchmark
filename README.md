# Steps to use

## Prerequisites
- Hadoop 3.1 or later cluster.
- Apache Hive.
- Between 15 minutes and 2 days to generate data (depending on the Scale Factor you choose and available hardware).
- Have the following packages. If your system does not have it, install it using apt-get or similar.
    ```
    bc, date, gcc, nohup, python3, timeout
    ```

## Clone
```
git clone https://github.com/kcheeeung/hive-benchmark.git
cd hive-benchmark/
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

# Troubleshooting

## Advanced Usage
Learn about [Advanced Usage and Recommended Setup](README_advanced.md)

## Did my X step finish?
Check `aaa_clock.txt` file.
```
ps -ef | grep sshuser
ps -ef | grep .sh
ps -ef | grep beeline
```

## How to debug
Debug is enabled by default.
```
DEBUG_SCRIPT=true
```
