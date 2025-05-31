delete from stage.user_order_log uol
where uol.date_time::Date = '{{ds}}';