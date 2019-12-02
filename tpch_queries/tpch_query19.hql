CREATE TABLE tpch_query19_result AS

SELECT sum(l_extendedprice * (1 - l_discount)) AS revenue
FROM lineitem
	,part
WHERE p_partkey = l_partkey
	AND
		l_shipmode IN (
			'AIR'
			,'AIR REG'
			)
	AND 
		l_shipinstruct = 'DELIVER IN PERSON' 
	AND (
			(
			p_brand = 'Brand#32'
			AND p_container IN (
				'SM CASE'
				,'SM BOX'
				,'SM PACK'
				,'SM PKG'
				)
			AND l_quantity >= 7
			AND l_quantity <= 7 + 10
			AND p_size BETWEEN 1 AND 5
			)
		OR (
			p_brand = 'Brand#35'
			AND p_container IN (
				'MED BAG'
				,'MED BOX'
				,'MED PKG'
				,'MED PACK'
				)
			AND l_quantity >= 15
			AND l_quantity <= 15 + 10
			AND p_size BETWEEN 1 AND 10
			)
		OR (
			p_brand = 'Brand#24'
			AND p_container IN (
				'LG CASE'
				,'LG BOX'
				,'LG PACK'
				,'LG PKG'
				)
			AND l_quantity >= 26
			AND l_quantity <= 26 + 10
			AND p_size BETWEEN 1 AND 15
			)
		);