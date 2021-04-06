use ${DB};

-- primary keys
alter table PART add constraint ${DB}_pk_pk primary key (P_PARTKEY) disable novalidate rely;
alter table SUPPLIER add constraint ${DB}_pk_ssk primary key (S_SUPPKEY) disable novalidate rely;
alter table PARTSUPP add constraint ${DB}_pk_pspk primary key (PS_PARTKEY) disable novalidate rely;
alter table PARTSUPP add constraint ${DB}_pk_pssk primary key (PS_SUPPKEY) disable novalidate rely;
alter table CUSTOMER add constraint ${DB}_pk_cck primary key (C_CUSTKEY) disable novalidate rely;
alter table ORDERS add constraint ${DB}_pk_ook primary key (O_ORDERKEY) disable novalidate rely;
alter table LINEITEM add constraint ${DB}_pk_lok primary key (L_ORDERKEY) disable novalidate rely;
alter table LINEITEM add constraint ${DB}_pk_lln primary key (L_LINENUMBER) disable novalidate rely;
alter table NATION add constraint ${DB}_pk_nnk primary key (N_NATIONKEY) disable novalidate rely;
alter table REGION add constraint ${DB}_pk_rrk primary key (R_REGIONKEY) disable novalidate rely;

-- foreign keys



