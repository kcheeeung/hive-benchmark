DROP VIEW IF EXISTS q2_min_ps_supplycost;

CREATE VIEW q2_min_ps_supplycost
AS
SELECT p_partkey AS min_p_partkey
	,min(ps_supplycost) AS min_ps_supplycost
FROM part
	,partsupp
	,supplier
	,nation
	,region
WHERE p_partkey = ps_partkey
	AND s_suppkey = ps_suppkey
	AND s_nationkey = n_nationkey
	AND n_regionkey = r_regionkey
	AND r_name = 'EUROPE'
GROUP BY p_partkey;

CREATE TABLE tpch_query2_result AS

SELECT s_acctbal
	,s_name
	,n_name
	,p_partkey
	,p_mfgr
	,s_address
	,s_phone
	,s_comment
FROM part
	,supplier
	,partsupp
	,nation
	,region
	,q2_min_ps_supplycost
WHERE p_partkey = ps_partkey
	AND s_suppkey = ps_suppkey
	AND p_size = 37
	AND p_type LIKE '%COPPER'
	AND s_nationkey = n_nationkey
	AND n_regionkey = r_regionkey
	AND r_name = 'EUROPE'
	AND ps_supplycost = min_ps_supplycost
	AND p_partkey = min_p_partkey
ORDER BY s_acctbal DESC
	,n_name
	,s_name
	,p_partkey limit 100;