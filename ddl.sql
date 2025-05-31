-- Дополнянем календарь свежими данными за актуальные года
-- Добавляем атрибут week_of_year

CREATE TABLE mart.d_calendar (
	date_id int NOT NULL,
	date_actual date not null,
	day_num int4 NULL,
	week_of_year int4 null,
	month_num int4 NULL,
	month_name varchar(10) NULL,
	year_num int4 NULL,
	CONSTRAINT d_calendar_pkey PRIMARY KEY (date_id)
);
CREATE INDEX d_calendar1 ON mart.d_calendar USING btree (date_id);


insert into mart.d_calendar
    select TO_char(date::date, 'YYYYMMDD')::int as date_id,
    		date::date as date_actual,
           EXTRACT(day FROM date) as day_num,
           extract (week from date) as week_of_year,
           extract(month FROM date) as month_num,
           TO_CHAR(date, 'Month') as month_name,
           extract(year FROM date) as year_num
      from generate_series('2020-01-01'::date,
                           '2026-01-01'::date,
                           '1 day')
           as t(date); 

-- До запуска DAG пересчитали таблицу sales
-- Добавили атрибут status, со значением 'shipped'

drop table if exists mart.f_sales;
create table mart.f_sales(
	date_id int references mart.d_calendar(date_id) on delete cascade not NULL,
	item_id int references mart.d_item(item_id) on delete cascade not NULL,
	customer_id int references mart.d_customer(customer_id) on delete cascade not NULL,
	city_id int not NULL,
	quantity int,
	payment_amount int,
	status varchar(10)
	);

insert into mart.f_sales
select 
	TO_CHAR(date_time::date, 'YYYYMMDD')::int as date_id
	,item_id
	,customer_id
	,city_id
	,quantity
	,payment_amount
	,null
from stage.user_order_log;

update mart.f_sales set status = 'shipped';

--DDL для f_customer_retention
create TABLE mart.f_customer_retention
(
    new_customers_count int NULL,
    returning_customers_count int NULL,
    refunded_customer_count int NULL,
    period_name varchar(100) NOT NULL,
    period_id int NOT NULL,
    item_id int NOT NULL,
    new_customers_revenue bigint NULL,
    returning_customers_revenue bigint NULL,
    customers_refunded int NULL
);

--Добавили атрбут в user_order_log
alter table stage.user_order_log add column status varchar(10);
