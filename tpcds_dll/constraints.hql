use ${DB};

-- primary keys
alter table customer_address add constraint ${DB}_pk_ca primary key (ca_address_sk) disable novalidate rely;
alter table customer_demographics add constraint ${DB}_pk_cd primary key (cd_demo_sk) disable novalidate rely;
alter table date_dim add constraint ${DB}_pk_dd primary key (d_date_sk) disable novalidate rely;
alter table warehouse add constraint ${DB}_pk_w primary key (w_warehouse_sk) disable novalidate rely;
alter table ship_mode add constraint ${DB}_pk_sm primary key (sm_ship_mode_sk) disable novalidate rely;
alter table time_dim add constraint ${DB}_pk_td primary key (t_time_sk) disable novalidate rely;
alter table reason add constraint ${DB}_pk_r primary key (r_reason_sk) disable novalidate rely;
alter table income_band add constraint ${DB}_pk_ib primary key (ib_income_band_sk) disable novalidate rely;
alter table item add constraint ${DB}_pk_i primary key (i_item_sk) disable novalidate rely;
alter table store add constraint ${DB}_pk_s primary key (s_store_sk) disable novalidate rely;
alter table call_center add constraint ${DB}_pk_cc primary key (cc_call_center_sk) disable novalidate rely;
alter table customer add constraint ${DB}_pk_c primary key (c_customer_sk) disable novalidate rely;
alter table web_site add constraint ${DB}_pk_ws primary key (web_site_sk) disable novalidate rely;
alter table store_returns add constraint ${DB}_pk_sr primary key (sr_item_sk, sr_ticket_number) disable novalidate rely;
alter table household_demographics add constraint ${DB}_pk_hd primary key (hd_demo_sk) disable novalidate rely;
alter table web_page add constraint ${DB}_pk_wp primary key (wp_web_page_sk) disable novalidate rely;
alter table promotion add constraint ${DB}_pk_p primary key (p_promo_sk) disable novalidate rely;
alter table catalog_page add constraint ${DB}_pk_cp primary key (cp_catalog_page_sk) disable novalidate rely;
alter table inventory add constraint ${DB}_pk_in primary key (inv_date_sk, inv_item_sk, inv_warehouse_sk) disable novalidate rely;
alter table catalog_returns add constraint ${DB}_pk_cr primary key (cr_item_sk, cr_order_number) disable novalidate rely;
alter table web_returns add constraint ${DB}_pk_wr primary key (wr_item_sk, wr_order_number) disable novalidate rely;
alter table web_sales add constraint ${DB}_pk_ws2 primary key (ws_item_sk, ws_order_number) disable novalidate rely;
alter table catalog_sales add constraint ${DB}_pk_cs primary key (cs_item_sk, cs_order_number) disable novalidate rely;
alter table store_sales add constraint ${DB}_pk_ss primary key (ss_item_sk, ss_ticket_number) disable novalidate rely;

-- not null
alter table customer_address change column ca_address_sk ca_address_sk integer constraint ${DB}_nn_ca_address_sk not null disable novalidate rely;
alter table customer_address change column ca_address_id ca_address_id char(16) constraint ${DB}_nn_ca_address_id not null disable novalidate rely;

alter table customer_demographics change column cd_demo_sk cd_demo_sk integer constraint ${DB}_nn_cd_demo_sk not null disable novalidate rely;

alter table date_dim change column d_date_sk d_date_sk integer constraint ${DB}_nn_d_date_sk not null disable novalidate rely;
alter table date_dim change column d_date_id d_date_id char(16) constraint ${DB}_nn_d_date_id not null disable novalidate rely;

alter table warehouse change column w_warehouse_sk w_warehouse_sk integer constraint ${DB}_nn_w_warehouse_sk not null disable novalidate rely;
alter table warehouse change column w_warehouse_id w_warehouse_id char(16) constraint ${DB}_nn_w_warehouse_id not null disable novalidate rely;

alter table ship_mode change column sm_ship_mode_sk sm_ship_mode_sk integer constraint ${DB}_nn_sm_ship_mode_sk not null disable novalidate rely;
alter table ship_mode change column sm_ship_mode_id sm_ship_mode_id char(16) constraint ${DB}_nn_sm_ship_mode_id not null disable novalidate rely;

alter table time_dim change column t_time_sk t_time_sk integer constraint ${DB}_nn_t_time_sk not null disable novalidate rely;
alter table time_dim change column t_time_id t_time_id char(16) constraint ${DB}_nn_t_time_id not null disable novalidate rely;

alter table reason change column r_reason_sk r_reason_sk integer constraint ${DB}_nn_r_reason_sk not null disable novalidate rely;
alter table reason change column r_reason_id r_reason_id char(16) constraint ${DB}_nn_r_reason_id not null disable novalidate rely;

alter table income_band change column ib_income_band_sk ib_income_band_sk integer constraint ${DB}_nn_ib_income_band_sk not null disable novalidate rely;

alter table item change column i_item_sk i_item_sk integer constraint ${DB}_nn_i_item_sk not null disable novalidate rely;
alter table item change column i_item_id i_item_id char(16) constraint ${DB}_nn_i_item_id not null disable novalidate rely;

alter table store change column s_store_sk s_store_sk integer constraint ${DB}_nn_s_store_sk not null disable novalidate rely;
alter table store change column s_store_id s_store_id char(16) constraint ${DB}_nn_s_store_id not null disable novalidate rely;

alter table call_center change column cc_call_center_sk cc_call_center_sk integer constraint ${DB}_nn_cc_call_center_sk not null disable novalidate rely;
alter table call_center change column cc_call_center_id cc_call_center_id char(16) constraint ${DB}_nn_cc_call_center_id not null disable novalidate rely;

alter table customer change column c_customer_sk c_customer_sk integer constraint ${DB}_nn_c_customer_sk not null disable novalidate rely;
alter table customer change column c_customer_id c_customer_id char(16) constraint ${DB}_nn_c_customer_id not null disable novalidate rely;

alter table web_site change column web_site_sk web_site_sk integer constraint ${DB}_nn_web_site_sk not null disable novalidate rely;
alter table web_site change column web_site_id web_site_id char(16) constraint ${DB}_nn_web_site_id not null disable novalidate rely;

alter table store_returns change column sr_item_sk sr_item_sk integer constraint ${DB}_nn_sr_item_sk not null disable novalidate rely;
alter table store_returns change column sr_ticket_number sr_ticket_number integer constraint ${DB}_nn_sr_ticket_number not null disable novalidate rely;

alter table household_demographics change column hd_demo_sk hd_demo_sk integer constraint ${DB}_nn_hd_demo_sk not null disable novalidate rely;

alter table web_page change column wp_web_page_sk wp_web_page_sk integer constraint ${DB}_nn_wp_web_page_sk not null disable novalidate rely;
alter table web_page change column wp_web_page_id wp_web_page_id char(16) constraint ${DB}_nn_wp_web_page_id not null disable novalidate rely;

alter table promotion change column p_promo_sk p_promo_sk integer constraint ${DB}_nn_p_promo_sk not null disable novalidate rely;
alter table promotion change column p_promo_id p_promo_id char(16) constraint ${DB}_nn_p_promo_id not null disable novalidate rely;

alter table catalog_page change column cp_catalog_page_sk cp_catalog_page_sk integer constraint ${DB}_nn_cp_catalog_page_sk not null disable novalidate rely;
alter table catalog_page change column cp_catalog_page_id cp_catalog_page_id char(16) constraint ${DB}_nn_cp_catalog_page_id not null disable novalidate rely;

alter table inventory change column inv_date_sk inv_date_sk integer constraint ${DB}_nn_inv_date_sk not null disable novalidate rely;
alter table inventory change column inv_item_sk inv_item_sk integer constraint ${DB}_nn_inv_item_sk not null disable novalidate rely;
alter table inventory change column inv_warehouse_sk inv_warehouse_sk integer constraint ${DB}_nn_inv_warehouse_sk not null disable novalidate rely;

alter table catalog_returns change column cr_item_sk cr_item_sk integer constraint ${DB}_nn_cr_item_sk not null disable novalidate rely;
alter table catalog_returns change column cr_order_number cr_order_number integer constraint ${DB}_nn_cr_order_number not null disable novalidate rely;

alter table web_returns change column wr_item_sk wr_item_sk integer constraint ${DB}_nn_wr_item_sk not null disable novalidate rely;
alter table web_returns change column wr_order_number wr_order_number integer constraint ${DB}_nn_wr_order_number not null disable novalidate rely;

alter table web_sales change column ws_item_sk ws_item_sk integer constraint ${DB}_nn_ws_item_sk not null disable novalidate rely;
alter table web_sales change column ws_order_number ws_order_number integer constraint ${DB}_nn_ws_order_number not null disable novalidate rely;

alter table catalog_sales change column cs_item_sk cs_item_sk integer constraint ${DB}_nn_cs_item_sk not null disable novalidate rely;
alter table catalog_sales change column cs_order_number cs_order_number integer constraint ${DB}_nn_cs_order_number not null disable novalidate rely;

alter table store_sales change column ss_item_sk ss_item_sk integer constraint ${DB}_nn_ss_item_sk not null disable novalidate rely;
alter table store_sales change column ss_ticket_number ss_ticket_number integer constraint ${DB}_nn_ss_ticket_number not null disable novalidate rely;
