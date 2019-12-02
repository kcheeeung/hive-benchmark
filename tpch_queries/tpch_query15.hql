DROP VIEW revenue_cached;

DROP VIEW max_revenue_cached;

CREATE VIEW revenue_cached
AS
SELECT l_suppkey AS supplier_no
	,sum(l_extendedprice * (1 - l_discount)) AS total_revenue
FROM lineitem
WHERE l_shipdate >= '1996-01-01'
	AND l_shipdate < '1996-04-01'
GROUP BY l_suppkey;

CREATE VIEW max_revenue_cached
AS
SELECT max(total_revenue) AS max_revenue
FROM revenue_cached;

CREATE TABLE tpch_query15_result AS

SELECT s_suppkey
	,s_name
	,s_address
	,s_phone
	,total_revenue
FROM supplier
	,revenue_cached
	,max_revenue_cached
WHERE s_suppkey = supplier_no
	AND total_revenue = max_revenue
ORDER BY s_suppkey;