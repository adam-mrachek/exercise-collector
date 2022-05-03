require 'pg'
require 'pry'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'exercise_collector')
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def all_exercises
    sql = <<~SQL
      SELECT * FROM exercises;
    SQL

    query(sql)
  end

  def all_equipment
    sql = <<~SQL
      SELECT * FROM equipment;
    SQL

    query(sql)
  end

  def all_muscles
    sql = <<~SQL
      SELECT * FROM muscle_groups;
    SQL

    query(sql)
  end

  def find_exercise(id)
    sql = <<~SQL
      SELECT * FROM exercises
      WHERE id = $1
    SQL

    query(sql, id).first
  end

  def find_equipment(id)
    sql = <<~SQL
      SELECT * FROM equipment
      WHERE id = $1;
    SQL

    query(sql, id)
  end

  def find_muscle(id)
    sql = <<~SQL
      SELECT * FROM muscle_groups
      WHERE id = $1;
    SQL

    query(sql, id)
  end

  def add_exercise(exercise_name, equipment_ids, muscle_group_ids)
    sql = <<~SQL
      INSERT INTO exercises (name)
      VALUES ($1)
      RETURNING id;
    SQL

    result = query(sql, exercise_name)
    exercise_id = result.first["id"].to_i

    add_equipment_exercises(exercise_id, equipment_ids)
    add_muscle_groups_exercises(exercise_id, muscle_group_ids)
    result
  end

  def add_equipment_exercises(exercise_id, equipment)
    sql = <<~SQL
      INSERT INTO exercises_equipment (equipment_id, exercise_id)
      VALUES ($1, $2);
    SQL

    equipment.each do |equip|
      query(sql, equip, exercise_id)
    end
  end

  def add_muscle_groups_exercises(exercise_id, muscle_groups)
    sql = <<~SQL
      INSERT INTO exercises_muscle_groups (exercise_id, muscle_group_id)
      VALUES ($1, $2);
    SQL

    muscle_groups.each do |muscle_group|
      query(sql, exercise_id, muscle_group)
    end
  end

  def update_exercise(id, new_name)
    sql = <<~SQL
      UPDATE exercises
      SET name = $1
      WHERE id = $2;
    SQL

    query(sql, new_name, id)
  end

  def update_muscle(id, new_name)
    sql = <<~SQL
      UPDATE muscle_groups
      SET name = $1
      WHERE id = $2;
    SQL

    query(sql, new_name, id)
  end

  def update_equipment(id, new_name)
    sql = <<~SQL
      UPDATE equipment
      SET name = $1
      WHERE id = $2;
    SQL

    query(sql, new_name, id)
  end

  def get_equipment_for_exercises(id)
    sql = <<~SQL
      SELECT equipment.name
      FROM equipment
      INNER JOIN exercises_equipment
              ON equipment.id = exercises_equipment.equipment_id
      INNER JOIN exercises
              ON exercises.id = exercises_equipment.exercise_id
      WHERE exercises.id = $1;
    SQL

    query(sql, id)
  end

  def exercise_muscle_groups(id)
    sql = <<~SQL
      SELECT muscle_groups.name
      FROM muscle_groups
      INNER JOIN exercises_muscle_groups
              ON muscle_groups.id = exercises_muscle_groups.muscle_group_id
      INNER JOIN exercises
              ON exercises.id = exercises_muscle_groups.exercise_id
      WHERE exercises.id = $1;
    SQL

    query(sql, id)
  end

  def add_equipment(name)
    sql = <<~SQL
      INSERT INTO equipment (name)
      VALUES ($1);
    SQL

    query(sql, name)
  end

  def add_muscle(name)
    sql = <<~SQL
      INSERT INTO muscle_groups (name)
      VALUES ($1);
    SQL

    query(sql, name)
  end

  def get_exercises_for_equipment(id)
    sql = <<~SQL
      SELECT exercises.name, exercises.id
      FROM exercises
      JOIN exercises_equipment
        ON exercises.id = exercises_equipment.exercise_id
      JOIN equipment
        ON equipment.id = exercises_equipment.equipment_id
      WHERE equipment.id = $1;
    SQL

    query(sql, id)
  end

  def get_exercises_for_muscle(id)
    sql = <<~SQL
      SELECT exercises.name, exercises.id
      FROM exercises
      JOIN exercises_muscle_groups
        ON exercises.id = exercises_muscle_groups.exercise_id
      JOIN muscle_groups
        ON muscle_groups.id = exercises_muscle_groups.muscle_group_id
      WHERE muscle_groups.id = $1;
    SQL

    query(sql, id)
  end

  def delete_exercise(id)
    sql = <<~SQL
      DELETE FROM exercises
      WHERE id = $1;
    SQL

    query(sql, id)
  end

  def delete_equipment(id)
    sql = <<~SQL
      DELETE FROM equipment
      WHERE id = $1;
    SQL

    query(sql, id)
  end

  def delete_muscle(id)
    sql = <<~SQL
      DELETE FROM muscle_groups
      WHERE id = $1;
    SQL

    query(sql, id)
  end
end