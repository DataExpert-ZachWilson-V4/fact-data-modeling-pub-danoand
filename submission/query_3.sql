-- Query to iteratively generate the user_devices_cumulated table
insert into danfanderson48529.user_devices_cumulated
-- cte to house the initial date
with cfg as (
    select date '2021-01-02' as start_date 
),
-- cte to fetch yesterday's cumulative table data (if it exists)
yday as (
        select * 
        from danfanderson48529.user_devices_cumulated
        where date = date_add('day', -1, (select start_date from cfg))
),
-- cte to fetch the current processing day's data
tday as (
    -- select the user_id, browser_type, and event_date from the web_events table
    select user_id,
        browser_type,
        CAST(event_time AS DATE) as event_date,
        count(event_time)
    from bootcamp.web_events evt
    -- join the event data with their associated device data
    left join bootcamp.devices dev on evt.device_id = dev.device_id
    where CAST(event_time AS DATE) = (select start_date from cfg)
    group by user_id, browser_type, CAST(event_time AS DATE)
)
-- select all of yesterday's user / device combinations and create any new user / device combinations for today
--    and append today's date to the dates_active array reflecting today's user activity
select 
    coalesce(yday.user_id, tday.user_id) as user_id,
    coalesce(yday.browser_type, tday.browser_type) as browser_type,
    case when tday.event_date is not null then array[tday.event_date] || coalesce(yday.dates_active, array[]) 
         else yday.dates_active 
    end as dates_active,
    (select start_date from cfg) as date
from yday
full outer join tday on yday.user_id = tday.user_id and yday.browser_type = tday.browser_type
