require 'pg'
require 'pry'

class MuscleGroup
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
      SELECT * FROM muscle_groups;
    SQL

    query(sql)
  end
end