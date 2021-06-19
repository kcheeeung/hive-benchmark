set hive.enforce.bucketing=true;
set hive.enforce.sorting=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=100000;
set hive.exec.max.dynamic.partitions=100000;
set hive.exec.max.created.files=1000000;
set hive.exec.parallel=true;
set hive.exec.reducers.max=${REDUCERS};

set hive.stats.autogather=true;
set hive.optimize.sort.dynamic.partition=true;

set tez.runtime.empty.partitions.info-via-events.enabled=true;
set tez.runtime.report.partition.stats=true;
-- fewer files for the NULL partition
set hive.tez.auto.reducer.parallelism=true;
set hive.tez.min.partition.factor=0.01; 
