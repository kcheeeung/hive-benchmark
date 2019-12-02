CREATE TABLE tpch_query4_result AS

SELECT o_orderpriority
	,count(*) AS order_count
FROM orders AS o
WHERE o_orderdate >= '1996-05-01'
	AND o_orderdate < '1996-08-01'
	AND EXISTS (
		SELECT *
		FROM lineitem
		WHERE l_orderkey = o.o_orderkey
			AND l_commitdate < l_receiptdate
		)
GROUP BY o_orderpriority
ORDER BY o_orderpriority;