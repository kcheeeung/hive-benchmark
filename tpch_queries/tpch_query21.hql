DROP VIEW q21_tmp1_cached;

DROP VIEW q21_tmp2_cached;

CREATE VIEW q21_tmp1_cached
AS
SELECT l_orderkey
	,count(DISTINCT l_suppkey) AS count_suppkey
	,max(l_suppkey) AS max_suppkey
FROM lineitem
WHERE l_orderkey IS NOT NULL
GROUP BY l_orderkey;

CREATE VIEW q21_tmp2_cached
AS
SELECT l_orderkey
	,count(DISTINCT l_suppkey) count_suppkey
	,max(l_suppkey) AS max_suppkey
FROM lineitem
WHERE l_receiptdate > l_commitdate
	AND l_orderkey IS NOT NULL
GROUP BY l_orderkey;

CREATE TABLE tpch_query21_result AS

SELECT s_name
	,count(1) AS numwait
FROM (
	SELECT s_name
	FROM (
		SELECT s_name
			,t2.l_orderkey
			,l_suppkey
			,count_suppkey
			,max_suppkey
		FROM q21_tmp2_cached t2
		RIGHT JOIN (
			SELECT s_name
				,l_orderkey
				,l_suppkey
			FROM (
				SELECT s_name
					,t1.l_orderkey
					,l_suppkey
					,count_suppkey
					,max_suppkey
				FROM q21_tmp1_cached t1
				INNER JOIN (
					SELECT s_name
						,l_orderkey
						,l_suppkey
					FROM orders o
					INNER JOIN (
						SELECT s_name
							,l_orderkey
							,l_suppkey
						FROM nation n
						INNER JOIN supplier s ON s.s_nationkey = n.n_nationkey
							AND n.n_name = 'SAUDI ARABIA'
						INNER JOIN lineitem l ON s.s_suppkey = l.l_suppkey
						WHERE l.l_receiptdate > l.l_commitdate
							AND l.l_orderkey IS NOT NULL
						) l1 ON o.o_orderkey = l1.l_orderkey
						AND o.o_orderstatus = 'F'
					) l2 ON l2.l_orderkey = t1.l_orderkey
				) a
			WHERE (count_suppkey > 1)
				OR (
					(count_suppkey = 1)
					AND (l_suppkey <> max_suppkey)
					)
			) l3 ON l3.l_orderkey = t2.l_orderkey
		) b
	WHERE (count_suppkey IS NULL)
		OR (
			(count_suppkey = 1)
			AND (l_suppkey = max_suppkey)
			)
	) c
GROUP BY s_name
ORDER BY numwait DESC
	,s_name limit 100;