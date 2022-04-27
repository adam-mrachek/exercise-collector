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

CREATE TABLE equipment_exercises (
  id serial PRIMARY KEY,
  exercise_id int NOT NULL REFERENCES exercises(id),
  equipment_id int NOT NULL REFERENCES equipment(id)
);

CREATE TABLE exercises_muscle_groups (
  id serial PRIMARY KEY,
  exercise_id int NOT NULL REFERENCES exercises(id),
  muscle_group_id int NOT NULL REFERENCES muscle_groups(id)
);