-- cte houses the initial processing date
WITH cfg_end as (
    SELECT date '2023-01-07' AS end_date 
),
cfg_str as (
    SELECT date_add('day', -6, (select end_date from cfg_end)) AS start_date 
),
-- tday fetches the device activity date for the current processing day
tday AS (
    SELECT * FROM danfanderson48529.user_devices_cumulated
    WHERE DATE = (select end_date from cfg_end)
),
-- date_list_int generates a list of dates from 2023-01-01 to 2023-01-07 and converts the dates_active array to a integer
-- calculated by taking 2 to the power of the difference between the sequence_date and the current date
date_list_int AS (
    SELECT 
        user_id,
        CAST(SUM(
                CASE
                    WHEN CONTAINS(dates_active, sequence_date) THEN POW(2, 31 - DATE_DIFF('day', sequence_date, DATE))
                ELSE 0
                END
            ) AS BIGINT) AS history_int
    FROM
        tday CROSS JOIN UNNEST (SEQUENCE((select start_date from cfg_str), (select end_date from cfg_end))) AS t (sequence_date)
    GROUP BY
        user_id
)
-- transform the integer history_int into a binary representation (string of 1s and 0s) that represent the user's daily device activity
SELECT
  *,
  TO_BASE(history_int, 2) AS history_in_binary,
  TO_BASE(
    FROM_BASE('11111110000000000000000000000000', 2),
    2
  ) AS weekly_base,
  BIT_COUNT(history_int, 64) AS num_days_active,
  BIT_COUNT(
    BITWISE_AND(
      history_int,
      FROM_BASE('11111110000000000000000000000000', 2)
    ),
    64
  ) > 0 AS is_weekly_active,
  BIT_COUNT(
    BITWISE_AND(
      history_int,
      FROM_BASE('00000001111111000000000000000000', 2)
    ),
    64
  ) > 0 AS is_weekly_active_last_week,
  BIT_COUNT(
    BITWISE_AND(
      history_int,
      FROM_BASE('11100000000000000000000000000000', 2)
    ),
    64
  ) > 0 AS is_active_last_three_days
FROM
  date_list_int