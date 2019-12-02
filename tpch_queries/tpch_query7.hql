CREATE TABLE tpch_query7_result AS

SELECT supp_nation
	,cust_nation
	,l_year
	,sum(volume) AS revenue
FROM (
	SELECT n1.n_name AS supp_nation
		,n2.n_name AS cust_nation
		,year(l_shipdate) AS l_year
		,l_extendedprice * (1 - l_discount) AS volume
	FROM supplier
		,lineitem
		,orders
		,customer
		,nation n1
		,nation n2
	WHERE s_suppkey = l_suppkey
		AND o_orderkey = l_orderkey
		AND c_custkey = o_custkey
		AND s_nationkey = n1.n_nationkey
		AND c_nationkey = n2.n_nationkey
		AND (
			(
				n1.n_name = 'KENYA'
				AND n2.n_name = 'PERU'
				)
			OR (
				n1.n_name = 'PERU'
				AND n2.n_name = 'KENYA'
				)
			)
		AND l_shipdate BETWEEN '1995-01-01'
			AND '1996-12-31'
	) AS shipping
GROUP BY supp_nation
	,cust_nation
	,l_year
ORDER BY supp_nation
	,cust_nation
	,l_year;