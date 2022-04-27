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

  def all_exercises
    sql = <<~SQL
      SELECT * FROM exercises;
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

  def add_exercise(exercise_name)
    sql = <<~SQL
      INSERT INTO exercises (name)
      VALUES ($1)
    SQL

    query(sql, exercise_name)
  end
end