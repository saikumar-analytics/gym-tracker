-- queries.sql
-- stuff to run after loading everything, mostly to convince myself
-- the trigger actually works and isn't just inserting garbage.

SELECT * FROM vw_personal_records;

-- bench press progression week over week
SELECT * FROM vw_progress_by_exercise WHERE exercise = 'Barbell Bench Press';

-- did volume actually go up, or did I just feel like it did
SELECT * FROM vw_weekly_volume;

-- log a set that should NOT beat the current squat PR, then check
-- personal_records didn't change for squat
SELECT log_set(8, 2, 2, 6, 72, 6);
SELECT * FROM vw_personal_records WHERE exercise = 'Back Squat';

-- log a set that SHOULD beat the current bench PR and check it updates
SELECT log_set(7, 1, 2, 3, 67.5, 9);
SELECT * FROM vw_personal_records WHERE exercise = 'Barbell Bench Press';

-- which exercise have I made the least progress on lately? (lowest
-- est. 1RM relative to its own first logged set)
WITH first_and_last AS (
    SELECT
        exercise,
        FIRST_VALUE(est_1rm_this_set) OVER (PARTITION BY exercise ORDER BY session_date) AS first_1rm,
        LAST_VALUE(est_1rm_this_set) OVER (PARTITION BY exercise ORDER BY session_date
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS latest_1rm
    FROM vw_progress_by_exercise
)
SELECT DISTINCT exercise, first_1rm, latest_1rm, ROUND(latest_1rm - first_1rm, 2) AS change_kg
FROM first_and_last
ORDER BY change_kg ASC;
