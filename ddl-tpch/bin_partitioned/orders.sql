create database if not exists ${DB};
use ${DB};

drop table if exists orders;
create table orders (
O_ORDERKEY BIGINT,
O_CUSTKEY BIGINT,
O_ORDERSTATUS varchar(1),
O_TOTALPRICE decimal(7,2),
O_ORDERPRIORITY char(15),
O_CLERK char(15),
O_SHIPPRIORITY INT,
O_COMMENT varchar(79))
partitioned by (O_ORDERDATE DATE)
stored as ${FILE};

INSERT OVERWRITE TABLE orders partition(O_ORDERDATE)
select 
O_ORDERKEY,
O_CUSTKEY,
O_ORDERSTATUS,
O_TOTALPRICE,
O_ORDERPRIORITY,
O_CLERK,
O_SHIPPRIORITY,
O_COMMENT,
O_ORDERDATE
from ${SOURCE}.orders;
