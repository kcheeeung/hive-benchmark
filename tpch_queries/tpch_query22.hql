DROP VIEW q22_customer_tmp_cached;

DROP VIEW q22_customer_tmp1_cached;

DROP VIEW q22_orders_tmp_cached;

CREATE VIEW IF NOT EXISTS q22_customer_tmp_cached AS
	SELECT c_acctbal
		,c_custkey
		,substr(c_phone, 1, 2) AS cntrycode
	FROM customer
	WHERE substr(c_phone, 1, 2) = '13'
		OR substr(c_phone, 1, 2) = '31'
		OR substr(c_phone, 1, 2) = '23'
		OR substr(c_phone, 1, 2) = '29'
		OR substr(c_phone, 1, 2) = '30'
		OR substr(c_phone, 1, 2) = '18'
		OR substr(c_phone, 1, 2) = '17';

CREATE VIEW

IF NOT EXISTS q22_customer_tmp1_cached AS
	SELECT avg(c_acctbal) AS avg_acctbal
	FROM q22_customer_tmp_cached
	WHERE c_acctbal > 0.00;

CREATE VIEW IF NOT EXISTS q22_orders_tmp_cached AS
	SELECT o_custkey
	FROM orders
	GROUP BY o_custkey;

CREATE TABLE tpch_query22_result AS

SELECT cntrycode
	,count(1) AS numcust
	,sum(c_acctbal) AS totacctbal
FROM (
	SELECT cntrycode
		,c_acctbal
		,avg_acctbal
	FROM q22_customer_tmp1_cached ct1
	INNER JOIN (
		SELECT cntrycode
			,c_acctbal
		FROM q22_orders_tmp_cached ot
		RIGHT JOIN q22_customer_tmp_cached ct ON ct.c_custkey = ot.o_custkey
		WHERE o_custkey IS NULL
		) ct2
	) a
WHERE c_acctbal > avg_acctbal
GROUP BY cntrycode
ORDER BY cntrycode;