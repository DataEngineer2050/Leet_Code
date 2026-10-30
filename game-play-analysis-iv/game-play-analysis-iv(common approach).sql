--The Initial Instinct: Self-Join with MIN()
--The most common approach is to find each player's first login using MIN(event_date) in a CTE, and then LEFT JOIN the original table back onto it to check for first_login + 1 day.
--The Problem: This forces a double table scan and an expensive join operation. On massive production datasets, this will crawl

use leet_code
GO
--Step 1: to get first_login date using MIN()
;WITH FirstLogin AS (
    SELECT 
        player_id,
        MIN(event_date) AS first_date
    FROM game_play_analysis
    GROUP BY player_id
)

-- Step 2: Main logic - to calculate fraction
SELECT 
ROUND(CAST(COUNT(DISTINCT ga.player_id) AS FLOAT) / 
(SELECT COUNT(DISTINCT player_id) FROM game_play_analysis), 2) AS fraction
FROM FirstLogin f
LEFT JOIN game_play_analysis AS ga 
    ON f.player_id = ga.player_id 
    AND ga.event_date = DATEADD(day, 1, f.first_date);
