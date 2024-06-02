-- 
-- Create a cumulative table that describes users, their browser type, and the dates they were active 
--     and the date the data was collected.
create or replace table danfanderson48529.user_devices_cumulated (
    user_id bigint,
    browser_type varchar,
    dates_active array(date),
    date date
)
-- use the Parquet format and partition the data by date
with (
    format = 'PARQUET',
    partitioning = ARRAY['date']
)