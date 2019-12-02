DROP VIEW q17_lineitem_tmp_cached;

CREATE VIEW q17_lineitem_tmp_cached
AS
SELECT l_partkey AS t_partkey
	,0.2 * avg(l_quantity) AS t_avg_quantity
FROM lineitem
GROUP BY l_partkey;

CREATE TABLE tpch_query17_result AS

SELECT sum(l_extendedprice) / 7.0 AS avg_yearly
FROM (
	SELECT l_quantity
		,l_extendedprice
		,t_avg_quantity
	FROM q17_lineitem_tmp_cached
	INNER JOIN (
		SELECT l_quantity
			,l_partkey
			,l_extendedprice
		FROM part
			,lineitem
		WHERE p_partkey = l_partkey
			AND p_brand = 'Brand#23'
			AND p_container = 'MED BOX'
		) l1 ON l1.l_partkey = t_partkey
	) a
WHERE l_quantity < t_avg_quantity;