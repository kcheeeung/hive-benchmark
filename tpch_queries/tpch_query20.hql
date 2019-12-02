DROP VIEW q20_tmp1_cached;

DROP VIEW q20_tmp2_cached;

DROP VIEW q20_tmp3_cached;

DROP VIEW q20_tmp4_cached;

CREATE VIEW q20_tmp1_cached
AS
SELECT DISTINCT p_partkey
FROM part
WHERE p_name LIKE 'forest%';

CREATE VIEW q20_tmp2_cached
AS
SELECT l_partkey
	,l_suppkey
	,0.5 * sum(l_quantity) AS sum_quantity
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
	AND l_shipdate < '1995-01-01'
GROUP BY l_partkey
	,l_suppkey;

CREATE VIEW q20_tmp3_cached
AS
SELECT ps_suppkey
	,ps_availqty
	,sum_quantity
FROM partsupp
	,q20_tmp1_cached
	,q20_tmp2_cached
WHERE ps_partkey = p_partkey
	AND ps_partkey = l_partkey
	AND ps_suppkey = l_suppkey;

CREATE VIEW q20_tmp4_cached
AS
SELECT ps_suppkey
FROM q20_tmp3_cached
WHERE ps_availqty > sum_quantity
GROUP BY ps_suppkey;

CREATE TABLE tpch_query20_result AS

SELECT s_name
	,s_address
FROM supplier
	,nation
	,q20_tmp4_cached
WHERE s_nationkey = n_nationkey
	AND n_name = 'CANADA'
	AND s_suppkey = ps_suppkey
ORDER BY s_name;