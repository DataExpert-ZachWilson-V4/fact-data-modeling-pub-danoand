with cte_game_details as (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY game_id, player_id ORDER BY team_id DESC) AS row_num,
        gd.*
    FROM
        bootcamp.nba_game_details gd
)
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