-- schema.sql
-- tables for the gym log. nothing fancy, just what I actually track
-- when I'm at the gym: exercises, sessions, sets, and body weight over time.

DROP TABLE IF EXISTS personal_records CASCADE;
DROP TABLE IF EXISTS workout_sets CASCADE;
DROP TABLE IF EXISTS workout_sessions CASCADE;
DROP TABLE IF EXISTS body_measurements CASCADE;
DROP TABLE IF EXISTS exercises CASCADE;

-- master list of exercises so I'm not retyping "Barbell Bench Press" every time
CREATE TABLE exercises (
    exercise_id   SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL UNIQUE,
    muscle_group  VARCHAR(50) NOT NULL,
    equipment     VARCHAR(50)   -- barbell, dumbbell, machine, bodyweight, etc
);

-- one row per gym visit
CREATE TABLE workout_sessions (
    session_id        SERIAL PRIMARY KEY,
    session_date       DATE NOT NULL,
    day_label          VARCHAR(50),   -- "push day", "leg day", whatever I felt like calling it
    duration_minutes   INT,
    notes              TEXT
);

-- every single set gets its own row. I used to only log the top set
-- but that didn't show how I warmed up, so now it's everything.
CREATE TABLE workout_sets (
    set_id        SERIAL PRIMARY KEY,
    session_id     INT NOT NULL REFERENCES workout_sessions(session_id),
    exercise_id    INT NOT NULL REFERENCES exercises(exercise_id),
    set_number     INT NOT NULL CHECK (set_number > 0),
    reps           INT NOT NULL CHECK (reps > 0 AND reps <= 100),
    weight_kg      NUMERIC(6,2) NOT NULL CHECK (weight_kg >= 0),
    rpe            NUMERIC(3,1) CHECK (rpe BETWEEN 1 AND 10),  -- rate of perceived exertion, optional
    logged_at      TIMESTAMP DEFAULT now()
);

-- current best lift per exercise, kept up to date by a trigger
-- so I don't have to go figure out my own PRs by scrolling back through everything
CREATE TABLE personal_records (
    pr_id          SERIAL PRIMARY KEY,
    exercise_id     INT NOT NULL UNIQUE REFERENCES exercises(exercise_id),
    best_weight_kg  NUMERIC(6,2) NOT NULL,
    best_reps       INT NOT NULL,
    est_one_rep_max NUMERIC(6,2) NOT NULL,
    achieved_on     DATE NOT NULL,
    set_id          INT REFERENCES workout_sets(set_id)
);

-- bodyweight + body fat over time, separate from workouts since I don't
-- weigh in every single time I go to the gym
CREATE TABLE body_measurements (
    measurement_id  SERIAL PRIMARY KEY,
    measured_on      DATE NOT NULL UNIQUE,
    weight_kg        NUMERIC(5,2) NOT NULL CHECK (weight_kg > 0),
    body_fat_pct     NUMERIC(4,1) CHECK (body_fat_pct BETWEEN 0 AND 100),
    notes            TEXT
);
