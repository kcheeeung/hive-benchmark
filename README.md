# TPC-DS and TPC-H Benchmarks for Hive LLAP
Fully automated TPC-DS and TPC-H benchmarks. Automation optimized specifically for Azure HDInsight Interactive Query. Should also work in other engines check the **Credits** section.

## Prerequisites
- Apache Hive.
- Between 15 minutes and 2 days to generate data (depending on the Scale Factor you choose and available hardware).

# Individual Steps

## 1. Clone
```
git clone https://github.com/kcheeeung/hive-benchmark.git && cd hive-benchmark/
```

## 2. Generate the data and tables
Decide how much data you want. `SCALE` approximately is about # ~GB.
Supported `FORMAT` includes: `orc` and `parquet`

**Generic Usage**
```
nohup sh benchmark.sh SCALE FORMAT
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
- `SCALE` and `FORMAT` **must be the SAME as before or else it can't find the database name!**
- Add or change your desired `settings.hql` file or path
- Run the queries!

**TPC-DS**
```
nohup sh util_runtpcds.sh 10 orc
```
**TPC-H**
```
nohup sh util_runtpch.sh 10 orc
```

# Troubleshooting

## Did my X step finish?
Check the `aaa_clock.txt` file. Or run following:
```
ps -ef | grep '\.sh'
```

## Could not find database?
In the `settings.hql` file, add:
```
use DATABASENAME;
```

## Exception updating or communicating with metastore.
```
ERROR : FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.MoveTask.
Exception updating metastore for acid table

ERROR : FAILED: Error in acquiring locks: Error communicating with the 
metastore org.apache.hadoop.hive.ql.lockmgr.LockException.
```
Your SQL server likely has technical limitations. Check your metastore logs if you have `"The incoming request has too many parameters."` Change or add the following settings in `hive-site.xml` and restart Hive.
```
hive.direct.sql.max.elements.values.clause=200
hive.direct.sql.max.elements.in.clause=200
```

## Data generation is taking long.
This repository uses a Python user defined function. LLAP does not allow UDFs and was turned off.

# Credits
- https://github.com/dharmeshkakadia/tpcds-hdinsight
- https://github.com/dharmeshkakadia/tpch-hdinsight
- https://github.com/asonje/PAT
