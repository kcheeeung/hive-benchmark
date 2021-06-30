create database if not exists ${DB};
use ${DB};

drop table if exists part;
create external table part (
    P_PARTKEY BIGINT,
    P_NAME varchar(55),
    P_MFGR char(25),
    P_BRAND char(10),
    P_TYPE varchar(25),
    P_SIZE INT,
    P_CONTAINER char(10),
    P_RETAILPRICE decimal(7,2),
    P_COMMENT varchar(23)) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE 
LOCATION '${LOCATION}/part/';

drop table if exists supplier;
create external table supplier (
    S_SUPPKEY BIGINT,
    S_NAME char(25),
    S_ADDRESS varchar(40),
    S_NATIONKEY BIGINT,
    S_PHONE char(15),
    S_ACCTBAL decimal(7,2),
    S_COMMENT varchar(101)) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE 
LOCATION '${LOCATION}/supplier/';

drop table if exists partsupp;
create external table partsupp (
    PS_PARTKEY BIGINT,
    PS_SUPPKEY BIGINT,
    PS_AVAILQTY INT,
    PS_SUPPLYCOST decimal(7,2),
    PS_COMMENT varchar(199))
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION'${LOCATION}/partsupp';

drop table if exists customer;
create external table customer (
    C_CUSTKEY BIGINT,
    C_NAME varchar(25),
    C_ADDRESS varchar(40),
    C_NATIONKEY BIGINT,
    C_PHONE char(15),
    C_ACCTBAL decimal(7,2),
    C_MKTSEGMENT char(10),
    C_COMMENT varchar(117))
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${LOCATION}/customer';

drop table if exists orders;
create external table orders (
    O_ORDERKEY BIGINT,
    O_CUSTKEY BIGINT,
    O_ORDERSTATUS varchar(1),
    O_TOTALPRICE decimal(7,2),
    O_ORDERDATE DATE,
    O_ORDERPRIORITY char(15),
    O_CLERK char(15),
    O_SHIPPRIORITY INT,
    O_COMMENT varchar(79))
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${LOCATION}/orders';

drop table if exists lineitem;
create external table lineitem (
    L_ORDERKEY BIGINT,
    L_PARTKEY BIGINT,
    L_SUPPKEY BIGINT,
    L_LINENUMBER INT,
    L_QUANTITY decimal(7,2),
    L_EXTENDEDPRICE decimal(7,2),
    L_DISCOUNT decimal(7,2),
    L_TAX decimal(7,2),
    L_RETURNFLAG char(1),
    L_LINESTATUS char(1),
    L_SHIPDATE DATE,
    L_COMMITDATE DATE,
    L_RECEIPTDATE DATE,
    L_SHIPINSTRUCT char(25),
    L_SHIPMODE char(10),
    L_COMMENT varchar(44))
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE 
LOCATION '${LOCATION}/lineitem';

drop table if exists nation;
create external table nation (
    N_NATIONKEY BIGINT,
    N_NAME char(25),
    N_REGIONKEY BIGINT,
    N_COMMENT varchar(152))
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${LOCATION}/nation';

drop table if exists region;
create external table region (
    R_REGIONKEY BIGINT,
    R_NAME char(25),
    R_COMMENT varchar(152))
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${LOCATION}/region';
