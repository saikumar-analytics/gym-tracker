-- views.sql
-- the stuff I actually look at after a workout.

-- current best lift for every exercise I've logged
CREATE OR REPLACE VIEW vw_personal_records AS
SELECT
    e.name AS exercise,
    e.muscle_group,
    pr.best_weight_kg,
    pr.best_reps,
    pr.est_one_rep_max,
    pr.achieved_on
FROM personal_records pr
JOIN exercises e ON e.exercise_id = pr.exercise_id
ORDER BY e.muscle_group, e.name;

-- every set ever logged for a given exercise, in order, so I can see
-- if I'm actually progressing or just spinning my wheels
CREATE OR REPLACE VIEW vw_progress_by_exercise AS
SELECT
    e.name AS exercise,
    ws.session_date,
    s.set_number,
    s.reps,
    s.weight_kg,
    s.rpe,
    ROUND(s.weight_kg * (1 + s.reps::NUMERIC / 30), 2) AS est_1rm_this_set
FROM workout_sets s
JOIN exercises e          ON e.exercise_id = s.exercise_id
JOIN workout_sessions ws  ON ws.session_id = s.session_id
ORDER BY e.name, ws.session_date, s.set_number;

-- total volume (sets x reps x weight) per week, just to see if I'm
-- doing more or less work overall, not just chasing single numbers
CREATE OR REPLACE VIEW vw_weekly_volume AS
SELECT
    date_trunc('week', ws.session_date)::date AS week_start,
    SUM(s.reps * s.weight_kg) AS total_volume_kg
FROM workout_sets s
JOIN workout_sessions ws ON ws.session_id = s.session_id
GROUP BY date_trunc('week', ws.session_date)
ORDER BY week_start;
