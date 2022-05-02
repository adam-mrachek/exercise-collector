CREATE TABLE exercises (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE videos (
  id serial PRIMARY KEY,
  link text NOT NULL,
  exercise_id int NOT NULL REFERENCES exercises(id)
);

CREATE TABLE muscle_groups (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE equipment (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE exercises_equipment (
  id serial PRIMARY KEY,
  exercise_id int NOT NULL REFERENCES exercises(id)
                  ON DELETE CASCADE,
  equipment_id int NOT NULL REFERENCES equipment(id)
                   ON DELETE CASCADE
);

CREATE TABLE exercises_muscle_groups (
  id serial PRIMARY KEY,
  exercise_id int NOT NULL REFERENCES exercises(id)
                  ON DELETE CASCADE,
  muscle_group_id int NOT NULL REFERENCES muscle_groups(id)
                      ON DELETE CASCADE
);

ALTER TABLE exercises_equipment
ADD CONSTRAINT unique_exercises_equipment UNIQUE (exercise_id, equipment_id);

ALTER TABLE exercises_muscle_groups
ADD CONSTRAINT unique_exercises_muscle_groups UNIQUE (exercise_id, muscle_group_id);