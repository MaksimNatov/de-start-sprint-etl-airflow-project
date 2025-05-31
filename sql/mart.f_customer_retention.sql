insert into mart.f_customer_retention (
    new_customers_count, returning_customers_count, refunded_customer_count, period_name, period_id,
    item_id, new_customers_revenue, returning_customers_revenue, customers_refunded
)
with orders as
(
    select 
        fs.item_id,
        fs.customer_id,
        fs.status,
        dc.week_of_year as period_id,
        sum(payment_amount) as payment_amount,
        count(*) as cnt
    from mart.f_sales fs
    join mart.d_calendar dc 
        on fs.date_id = dc.date_id 
        and dc.week_of_year = extract('week' from '{{ ds }}'::date)
    group by 1,2,3,4
)
select
    sum(case when cnt = 1 then 1 end) as new_customers_count,
    coalesce(sum(case when cnt > 1 then 1 end), 0) as returning_customers_count,
    coalesce(sum(case when status = 'refunded' then 1 end), 0) as refunded_customer_count,
    'weekly' as period_name,
    period_id,
    item_id,
    sum(case when cnt = 1 then payment_amount end) as new_customers_revenue,
    coalesce(sum(case when cnt > 1 then payment_amount end), 0) as returning_customers_revenue,
    coalesce(sum(case when status = 'refunded' then cnt end), 0) as customers_refunded
from orders o
group by 4,5,6;