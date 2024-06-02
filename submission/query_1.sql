with cte_game_details as (
    SELECT
        -- partition by game_id, team_id, player_id and identify the row number for each instance
        ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) AS row_num,
        gd.*
    FROM
        bootcamp.nba_game_details gd
)
-- select the first row from the game details CTE for each game_id, team_id, player_id combination
select
    game_id,
    team_id,
    team_abbreviation,
    team_city,
    player_id,
    player_name,
    nickname,
    start_position,
    comment,
    min,
    fgm,
    fga,
    fg_pct,
    fg3m,
    fg3a,
    fg3_pct,
    ftm,
    fta,
    ft_pct,
    oreb,
    dreb,
    reb,
    ast,
    stl,
    blk,
    to,
    pf,
    pts,
    plus_minus
from
    cte_game_details
where
    row_num = 1