# gym-tracker

I got tired of trying to track my lifts in a notes app and just guessing
whether a set was actually a PR or not, so I built this instead. It's a
PostgreSQL database for logging workouts, and the part I actually wanted
to build (not just "a CRUD app for the gym") is that it auto-detects
personal records as you log sets, instead of you scrolling back through
weeks of notes trying to remember your old numbers.

## what's in here

- `exercises` — just a lookup table so I'm not retyping exercise names
- `workout_sessions` — one row per gym visit
- `workout_sets` — every single set, not just top sets. I started out only
  logging my heaviest set per exercise and quickly realized that told me
  nothing about how I actually warmed up or whether I was grinding reps
- `personal_records` — kept up to date automatically, see below
- `body_measurements` — weight/body fat over time, separate from workouts
  since I don't weigh in every single time I'm at the gym

## the PR thing

This was the actual point of the project. There's a trigger on
`workout_sets` that runs after every insert, calculates an estimated
1-rep max for that set using the Epley formula (`weight * (1 + reps/30)`),
and compares it against whatever's currently in `personal_records` for
that exercise. If the new set is better, it updates the record. If not,
it just leaves it alone.

I capped it so the formula doesn't run on sets over 12 reps, because
Epley (and basically every 1RM formula) gets pretty unreliable once
you're doing higher-rep sets — the numbers it spits out stop meaning
anything useful past that point.

## files, in the order you'd actually want to run them

1. `schema.sql`
2. `functions_and_triggers.sql`
3. `sample_data.sql` — a few weeks of a push/pull/legs split, logged
   through `log_set()` rather than raw inserts
4. `views.sql`
5. `queries.sql` — mostly me checking that the PR trigger isn't lying to me

## things to try

```sql
SELECT * FROM vw_personal_records;

-- log something that should NOT beat an existing PR
SELECT log_set(8, 2, 2, 6, 72, 6);
SELECT * FROM vw_personal_records WHERE exercise = 'Back Squat';
-- should be unchanged

-- log something that SHOULD beat one
SELECT log_set(7, 1, 2, 3, 67.5, 9);
SELECT * FROM vw_personal_records WHERE exercise = 'Barbell Bench Press';
-- should update
```

## things I know are missing

Not pretending this is finished, a few things I just haven't gotten to:

- supersets aren't really modeled at all right now, every set is treated
  as standalone even if I did it back-to-back with another exercise
- no concept of a "program" or training block, it's just a flat log
- the 1RM formula is a rough estimate at best, especially for anyone
  newer to lifting where reps-in-reserve estimates are shakier
- haven't added anything for tracking rest time between sets, mostly
  because I never actually time my rests consistently enough for that
  data to mean anything

If I keep using this past the next few months I'll probably add a
`programs` table and start linking sessions to a plan instead of just
logging whatever I felt like doing that day.
