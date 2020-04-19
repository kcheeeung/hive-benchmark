SET mapred.reduce.tasks=${hiveconf:PARTS} ;

ADD FILE ${hiveconf:TPCDSBIN}/dsdgen;
ADD FILE ${hiveconf:TPCDSBIN}/tpcds.idx;
ADD FILE ${hiveconf:TPCDSBIN}/sequenceGenerator.py;
ADD FILE ${hiveconf:TPCDSBIN}/TPCDSgen.py;

FROM (
    SELECT TRANSFORM(x) 
    USING 'python sequenceGenerator.py "${hiveconf:SCALE}"' AS (key INT, value STRING) 
    FROM ( SELECT 1 x) t 
    DISTRIBUTE BY (hash(key) % "${hiveconf:PARTS}")
    ) d REDUCE d.key 
USING 'python TPCDSgen.py -s "${hiveconf:SCALE}" -o "${hiveconf:LOCATION}" -n "${hiveconf:PARTS}"' ;
