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
alter table SUPPLIER add constraint ${DB}_fk_ssnk foreign key (S_NATIONKEY) references NATION (N_NATIONKEY) disable novalidate rely;
alter table PARTSUPP add constraint ${DB}_fk_pppk foreign key (PS_PARTKEY) references SUPPLIER (P_PARTKEY) disable novalidate rely;
alter table PARTSUPP add constraint ${DB}_fk_ppsk foreign key (PS_SUPPKEY) references SUPPLIER (S_SUPPKEY) disable novalidate rely;
alter table CUSTOMER add constraint ${DB}_fk_ccnk foreign key (C_NATIONKEY) references NATION (N_NATIONKEY) disable novalidate rely;
alter table ORDERS add constraint ${DB}_fk_oock foreign key (O_CUSTKEY) references CUSTOMER (C_CUSTKEY) disable novalidate rely;
alter table LINEITEM add constraint ${DB}_fk_llok foreign key (L_ORDERKEY) references ORDERS (O_ORDERKEY) disable novalidate rely;
alter table LINEITEM add constraint ${DB}_fk_llpka foreign key (L_PARTKEY) references PARTSUPP (PS_PARTKEY) disable novalidate rely;
alter table LINEITEM add constraint ${DB}_fk_llpkb foreign key (L_PARTKEY) references PARTSUPP (PS_SUPPKEY) disable novalidate rely;
alter table LINEITEM add constraint ${DB}_fk_llpkb foreign key (L_SUPPKEY) references SUPPLIER (S_SUPPKEY) disable novalidate rely;
alter table NATION add constraint ${DB}_fk_nnrk foreign key (N_REGIONKEY) references REGION (R_REGIONKEY) disable novalidate rely;
