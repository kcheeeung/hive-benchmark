DROP VIEW q11_part_tmp_cached;

DROP VIEW q11_sum_tmp_cached;

CREATE VIEW q11_part_tmp_cached
AS
SELECT ps_partkey
	,sum(ps_supplycost * ps_availqty) AS part_value
FROM partsupp
	,supplier
	,nation
WHERE ps_suppkey = s_suppkey
	AND s_nationkey = n_nationkey
	AND n_name = 'GERMANY'
GROUP BY ps_partkey;

CREATE VIEW q11_sum_tmp_cached
AS
SELECT sum(part_value) AS total_value
FROM q11_part_tmp_cached;

CREATE TABLE tpch_query11_result AS

SELECT ps_partkey
	,part_value AS value
FROM (
	SELECT ps_partkey
		,part_value
		,total_value
	FROM q11_part_tmp_cached
	INNER JOIN q11_sum_tmp_cached
	) a
WHERE part_value > total_value * 0.0001
ORDER BY value DESC;