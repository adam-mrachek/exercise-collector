require 'pg'
require 'pry'

class Exercise
  def initialize(logger)
    @db = PG.connect(dbname: 'exercise_collector')
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def all
    sql = <<~SQL
      SELECT * FROM exercises;
    SQL

    query(sql)
  end

  def find(id)
    sql = <<~SQL
      SELECT * FROM exercises
      WHERE id = $1
    SQL

    query(sql, id).first
  end

  def add(exercise_name)
    sql = <<~SQL
      INSERT INTO exercises (name)
      VALUES ($1)
      RETURNING id;
    SQL

    result = query(sql, exercise_name)
    binding.pry
  end

  def add_equipment(exercise_id, *equipment)
    sql = <<~SQL
      INSERT INTO equipment_exercises (equipment_id, exercise_id)
      VALUES ($1, $2);
    SQL

    equipment.each do |equip|
      query(sql, [id, equip["id"]])
    end
  end

  def add_muscle_groups(exercise_id, *muscle_groups)
    sql = <<~SQL
      INSERT INTO exercises_muscle_groups (exercise_id, muscle_group_id)
      VALUES ($1, $2);
    SQL

    muscle_groups.each do |muscle_group|
      query(sql, [id, muscle_group["id"]])
    end
  end
end