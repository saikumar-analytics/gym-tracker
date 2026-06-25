-- sample_data.sql
-- a few weeks of a pretty normal push/pull/legs split. numbers are made up
-- but the progression is realistic (small jumps, the occasional bad day).

INSERT INTO exercises (name, muscle_group, equipment) VALUES
('Barbell Bench Press', 'Chest',     'barbell'),
('Back Squat',          'Legs',      'barbell'),
('Deadlift',             'Back',      'barbell'),
('Overhead Press',       'Shoulders', 'barbell'),
('Pull-up',              'Back',      'bodyweight'),
('Bicep Curl',           'Arms',      'dumbbell');

-- ===== Week 1 =====
INSERT INTO workout_sessions (session_date, day_label, duration_minutes, notes) VALUES
('2026-05-04', 'Push Day', 55, 'felt strong today'),
('2026-05-06', 'Pull Day', 60, NULL),
('2026-05-08', 'Leg Day',  65, 'forgot knee sleeves, regretted it');

-- push day -- bench + ohp
SELECT log_set(1, 1, 1, 8, 50, 6);
SELECT log_set(1, 1, 2, 6, 55, 7);
SELECT log_set(1, 1, 3, 5, 60, 8.5);
SELECT log_set(1, 4, 1, 8, 30, 6);
SELECT log_set(1, 4, 2, 6, 35, 7.5);

-- pull day -- pull-ups + curls
SELECT log_set(2, 5, 1, 8, 0, 6);   -- bodyweight pull-ups, weight_kg = 0 (no added load)
SELECT log_set(2, 5, 2, 6, 0, 7);
SELECT log_set(2, 6, 1, 12, 12, 6);
SELECT log_set(2, 6, 2, 10, 14, 7);

-- leg day -- squat + deadlift
SELECT log_set(3, 2, 1, 8, 70, 6);
SELECT log_set(3, 2, 2, 6, 80, 8);
SELECT log_set(3, 3, 1, 5, 90, 8);

-- ===== Week 2 -- this is where the PR trigger actually has something to do =====
INSERT INTO workout_sessions (session_date, day_label, duration_minutes, notes) VALUES
('2026-05-11', 'Push Day', 58, NULL),
('2026-05-13', 'Pull Day', 62, NULL),
('2026-05-15', 'Leg Day',  70, 'new squat PR, very happy');

SELECT log_set(4, 1, 1, 8, 52.5, 6);
SELECT log_set(4, 1, 2, 5, 62.5, 8);   -- beats last week's bench est. 1RM
SELECT log_set(4, 4, 1, 6, 37.5, 7);

SELECT log_set(5, 5, 1, 9, 0, 6);
SELECT log_set(5, 6, 1, 10, 14, 6.5);

SELECT log_set(6, 2, 1, 5, 85, 8);     -- new squat PR
SELECT log_set(6, 3, 1, 4, 95, 8.5);   -- new deadlift PR

-- ===== Week 3 -- a flat week, nothing beats the existing PRs, trigger should
-- leave personal_records alone for these lifts =====
INSERT INTO workout_sessions (session_date, day_label, duration_minutes, notes) VALUES
('2026-05-18', 'Push Day', 50, 'tired, kept it light'),
('2026-05-20', 'Leg Day',  60, NULL);

SELECT log_set(7, 1, 1, 8, 50, 5);   -- well under the week 2 bench PR
SELECT log_set(8, 2, 1, 8, 70, 6);   -- well under the squat PR

-- ===== bodyweight log, separate from the workouts =====
INSERT INTO body_measurements (measured_on, weight_kg, body_fat_pct, notes) VALUES
('2026-05-04', 78.2, 18.5, NULL),
('2026-05-11', 78.0, 18.2, NULL),
('2026-05-18', 77.6, 17.9, 'cut is going slow but going');
