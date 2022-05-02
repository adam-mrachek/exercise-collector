# frozen_string_literal: true

require "sinatra"

require_relative "database_persistence"

configure(:development) do
  require 'pry'
  require 'sinatra/reloader'
  also_reload "exercise.rb"
end

before do
  @db = DatabasePersistence.new(logger)
end

get '/' do
  @exercises = @db.all_exercises
  erb :index
end

get '/exercises/new' do
  @all_equipment = @db.all_equipment
  @all_muscle_groups = @db.all_muscle_groups

  erb :new
end

get '/exercises/:id' do
  @exercise_id = params[:id].to_i
  @exercise = @db.find_exercise(@exercise_id)
  @muscle_groups = @db.exercise_muscle_groups(@exercise_id)
  @equipment = @db.exercise_equipment(@exercise_id)

  erb :show
end

get '/exercises/:id/edit' do
  @exercise_id = params[:id].to_i
  @exercise = @db.find_exercise(@exercise_id)
  erb :edit
end

post '/exercises' do
  exercise_name = params[:exercise_name].strip
  equipment_ids = params[:equipment].map(&:to_i)
  muscle_group_ids = params[:muscle_groups].map(&:to_i)
  new_exercise = @db.add_exercise(exercise_name, equipment_ids, muscle_group_ids)

  redirect '/'
end

patch '/exercises/:id' do
  exercise_name = params[:exercise_name].strip
  exercise_id = params[:id].to_i
  @db.update_exercise(exercise_id, exercise_name)

  redirect "/exercises/#{exercise_id}"
end

post '/exercises/:id/delete' do
  exercise_id = params[:id]
  @db.delete_exercise(exercise_id)

  redirect '/'
end

get '/equipment' do
  @equipment = @db.all_equipment

  
end