SET mapred.reduce.tasks=${hiveconf:PARTS} ;

ADD FILE ${hiveconf:TPCHBIN}/dbgen;
ADD FILE ${hiveconf:TPCHBIN}/dists.dss;
ADD FILE ${hiveconf:TPCHBIN}/sequenceGenerator.py;
ADD FILE ${hiveconf:TPCHBIN}/TPCHgen.py;

FROM (
    SELECT TRANSFORM(x) 
    USING 'python sequenceGenerator.py "${hiveconf:SCALE}"' AS (key INT, value STRING) 
    FROM ( SELECT 1 x) t 
    DISTRIBUTE BY (hash(key) % "${hiveconf:PARTS}")
    ) d REDUCE d.key 
USING 'python TPCHgen.py -s "${hiveconf:SCALE}" -o "${hiveconf:LOCATION}" -n "${hiveconf:PARTS}"' ;
