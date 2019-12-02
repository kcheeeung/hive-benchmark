CREATE TABLE tpch_query3_result AS

SELECT l_orderkey
	,sum(l_extendedprice * (1 - l_discount)) AS revenue
	,o_orderdate
	,o_shippriority
FROM customer
	,orders
	,lineitem
WHERE c_mktsegment = 'BUILDING'
	AND c_custkey = o_custkey
	AND l_orderkey = o_orderkey
	AND o_orderdate < '1995-03-22'
	AND l_shipdate > '1995-03-22'
GROUP BY l_orderkey
	,o_orderdate
	,o_shippriority
ORDER BY revenue DESC
	,o_orderdate limit 10;