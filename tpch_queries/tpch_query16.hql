CREATE TABLE tpch_query16_result AS

SELECT p_brand
	,p_type
	,p_size
	,count(DISTINCT ps_suppkey) AS supplier_cnt
FROM partsupp
	,part
WHERE p_partkey = ps_partkey
	AND p_brand <> 'Brand#34'
	AND p_type NOT LIKE 'ECONOMY BRUSHED%'
	AND p_size IN (
		22
		,14
		,27
		,49
		,21
		,33
		,35
		,28
		)
	AND partsupp.ps_suppkey NOT IN (
		SELECT s_suppkey
		FROM supplier
		WHERE s_comment LIKE '%Customer%Complaints%'
		)
GROUP BY p_brand
	,p_type
	,p_size
ORDER BY supplier_cnt DESC
	,p_brand
	,p_type
	,p_size;