delete from mart.f_customer_retention
where period_id = (select week_of_year from mart.d_calendar dc where dc.date_actual::Date = '{{ds}}');