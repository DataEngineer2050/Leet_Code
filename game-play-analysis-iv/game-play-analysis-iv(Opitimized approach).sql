--The Optimization: Single Scan with LEAD()
--By switching to Window Functions, we can eliminate the join entirely and calculate everything in a single pass over the data.
--To handle duplicate same-day logs without sacrificing the single-scan performance benefits, we introduce a DISTINCT layer inside our CTE before running the window functions

WITH UniqueLogins AS (
    SELECT DISTINCT player_id, event_date 
    FROM game_play_analysis
),
NextLogins AS (
    SELECT 
        player_id,
        event_date,
        LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) AS next_login_date,
        ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY event_date) AS rn
    FROM game_play_analysis
)
SELECT 
    ROUND(
        SUM(CASE WHEN DATEADD(day, 1, event_date) = next_login_date THEN 1 ELSE 0 END) * 1.0 
        / COUNT(DISTINCT player_id), 2) AS fraction
FROM NextLogins
WHERE rn = 1;