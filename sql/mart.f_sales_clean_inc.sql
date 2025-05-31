delete from mart.f_sales fs
where fs.date_id = (select distinct date_id from mart.d_calendar dc where dc.date_actual::Date = '{{ds}}');