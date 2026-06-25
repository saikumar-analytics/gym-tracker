-- functions_and_triggers.sql
--
-- the main thing I wanted out of this project: log a set, and if it's
-- a new best, the PR table updates itself. no more manually checking
-- "wait, is 80kg x5 better than my old 85kg x3?" -- let the database do the math.
--
-- using the Epley formula for estimated 1-rep max:
--   1RM = weight * (1 + reps / 30)
-- it's not perfect (no formula is, especially past ~12 reps) but it's
-- good enough to compare two sets against each other.

CREATE OR REPLACE FUNCTION update_personal_record()
RETURNS TRIGGER AS $$
DECLARE
    new_est_1rm NUMERIC(6,2);
    existing_1rm NUMERIC(6,2);
BEGIN
    -- skip the formula for high rep sets, it gets unreliable past 12 reps
    -- and starts producing numbers that don't mean much
    IF NEW.reps > 12 THEN
        RETURN NEW;
    END IF;

    new_est_1rm := ROUND(NEW.weight_kg * (1 + NEW.reps::NUMERIC / 30), 2);

    SELECT est_one_rep_max INTO existing_1rm
    FROM personal_records
    WHERE exercise_id = NEW.exercise_id;

    IF existing_1rm IS NULL THEN
        -- first time logging this exercise, it's automatically a "PR"
        INSERT INTO personal_records (exercise_id, best_weight_kg, best_reps, est_one_rep_max, achieved_on, set_id)
        VALUES (NEW.exercise_id, NEW.weight_kg, NEW.reps, new_est_1rm,
                (SELECT session_date FROM workout_sessions WHERE session_id = NEW.session_id),
                NEW.set_id);

    ELSIF new_est_1rm > existing_1rm THEN
        UPDATE personal_records
        SET best_weight_kg  = NEW.weight_kg,
            best_reps        = NEW.reps,
            est_one_rep_max  = new_est_1rm,
            achieved_on      = (SELECT session_date FROM workout_sessions WHERE session_id = NEW.session_id),
            set_id           = NEW.set_id
        WHERE exercise_id = NEW.exercise_id;
    END IF;
    -- if it's not better than the existing record, just leave it alone

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_pr ON workout_sets;
CREATE TRIGGER trg_update_pr
AFTER INSERT ON workout_sets
FOR EACH ROW
EXECUTE FUNCTION update_personal_record();


-- small convenience function so logging a set is one call instead of
-- writing out a full INSERT every time. mostly just saves typing.
CREATE OR REPLACE FUNCTION log_set(
    p_session_id  INT,
    p_exercise_id  INT,
    p_set_number   INT,
    p_reps         INT,
    p_weight_kg    NUMERIC,
    p_rpe          NUMERIC DEFAULT NULL
) RETURNS INT AS $$
DECLARE
    v_set_id INT;
BEGIN
    INSERT INTO workout_sets (session_id, exercise_id, set_number, reps, weight_kg, rpe)
    VALUES (p_session_id, p_exercise_id, p_set_number, p_reps, p_weight_kg, p_rpe)
    RETURNING set_id INTO v_set_id;

    RETURN v_set_id;
END;
$$ LANGUAGE plpgsql;
