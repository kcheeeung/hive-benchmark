CREATE TABLE tpch_query6_result AS

SELECT sum(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= '1993-01-01'
	AND l_shipdate < '1994-01-01'
	AND l_discount BETWEEN 0.06 - 0.01
		AND 0.06 + 0.01
	AND l_quantity < 25;