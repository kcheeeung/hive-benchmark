# Advanced Usage

## Recommended Setup
The easiest way to setup is to create the tables using a Hadoop cluster. Once the tables are prepared, attach the target cluster to test.

The following items for table preparation:
- Hadoop cluster (at least 16 core worker nodes)
- External hive metastore
- Storage account
```
# Larger scales will require increased memory settings
# Example using 10 worker nodes (16 cores) at scale 10000 (10TB)
hive.tez.container.size=10240
hive.tez.java.opts=-Xmx8192M -Xms8192M
```

## Modifying Execution Method
File: `util_runtpcds.sh`

The current setup is to execute all queries sequentially once. `START` and `END` changes range of executed queries. `REPEAT` changes how many times a query is run before moving onto the next query (ex. you might modify this to measure the impact of caching).
```
START=1
END=99
REPEAT=1
for (( QUERY_NUM = $START; QUERY_NUM <= $END; QUERY_NUM++ )); do
    for (( j = 0; j < $REPEAT; j++ )); do
        ...
```

## Modifying Connection Method
File: `util_internalRunQuery.sh`

The default method is a direct connection to the headnode. Modify to any of the following `default`, `esp`, `gateway` and update the appropriate fields.
```
MODE='default'
```

## Modifying Connection String
File: `util_internalRunQuery.sh`

The default method connects to the current node using port 10001. To change hostname or port modify ``` `hostname -f`:10001 ```
```
timeout $TIME_TO_TIMEOUT beeline -u "jdbc:hive2://`hostname -f`:10001/${INTERNAL_DATABASE};transportMode=http"
```

# Further Troubleshooting

## Exception updating or communicating with metastore.
```
ERROR : FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.MoveTask.
Exception updating metastore for acid table

ERROR : FAILED: Error in acquiring locks: Error communicating with the 
metastore org.apache.hadoop.hive.ql.lockmgr.LockException.
```
Check your metastore logs if you have `"The incoming request has too many parameters."` Change or add the following settings in `hive-site.xml` and restart Hive.
```
hive.direct.sql.max.elements.values.clause=300
hive.direct.sql.max.elements.in.clause=300
```
