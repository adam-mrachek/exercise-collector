# frozen_string_literal: true

require "sinatra"

require_relative "database_persistence"

configure do
  enable :sessions
  set :sessions_secret, 'secret'
  set :erb, :escape_html => true
end

configure(:development) do
  require 'pry'
  require 'sinatra/reloader'
  also_reload "database_persistence.rb"
end

before do
  @db = DatabasePersistence.new(logger)
end

def error_for_name(name)
  if !(1..100).cover?(name.size)
    "Name must be between 1 and 100 characters."
  end
end

get '/' do
  redirect '/exercises'
end

get '/exercises' do
  @exercises = @db.all_exercises
  erb :"exercises/index"
end

get '/exercises/new' do
  @all_equipment = @db.all_equipment
  @all_muscle_groups = @db.all_muscles

  erb :"exercises/new"
end

get '/exercises/:id' do
  @exercise_id = params[:id].to_i
  @exercise = @db.find_exercise(@exercise_id)
  @muscle_groups = @db.exercise_muscle_groups(@exercise_id)
  @equipment = @db.get_equipment_for_exercises(@exercise_id)

  erb :"exercises/show"
end

get '/exercises/:id/edit' do
  @exercise_id = params[:id].to_i
  @exercise = @db.find_exercise(@exercise_id)
  erb :"exercises/edit"
end

post '/exercises' do
  exercise_name = params[:exercise_name].strip
  equipment_ids = params[:equipment].map(&:to_i)
  muscle_group_ids = params[:muscle_groups].map(&:to_i)

  if (error = error_for_name(exercise_name))
    session[:error] = error
    redirect '/exercises/new'
  else
    result = @db.add_exercise(exercise_name)
    
    if result == "PG::UniqueViolation"
      session[:error] = "#{exercise_name} already exists"
      redirect '/exercises/new'
    else
      exercise_id = result.first.to_i
      @db.add_equipment_exercises(exercise_id, equipment_ids)
      @db.add_muscle_groups_exercises(exercise_id, equipment_ids)
      redirect '/'
    end
  end
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

  erb :"equipment/index"
end

get '/equipment/new' do
  erb :"equipment/new"
end

get '/equipment/:id/edit' do
  equipment_id = params[:id].to_i
  @equipment = @db.find_equipment(equipment_id).first

  erb :"equipment/edit"
end

get '/equipment/:id' do
  @equipment_id = params[:id].to_i
  @equipment = @db.find_equipment(@equipment_id).first
  @exercises = @db.get_exercises_for_equipment(@equipment_id)

  erb :"equipment/show"
end

post '/equipment' do
  equipment_name = params[:equipment_name].strip

  if (error = error_for_name(equipment_name))
    session[:error] = error
    erb :"equipment/new"
  else
    result = @db.add_equipment(equipment_name)

    if result == "PG::UniqueViolation"
      session[:error] = "#{equipment_name} already exists"
      erb :"equipment/new"
    else
      redirect '/equipment'
    end
  end
end

patch '/equipment/:id' do
  new_name = params[:equipment_name].strip
  equipment_id = params[:id].to_i
  @db.update_equipment(equipment_id, new_name)

  redirect "/equipment/#{equipment_id}"
end

post '/equipment/:id/delete' do
  equipment_id = params[:id].to_i
  @db.delete_equipment(equipment_id)

  redirect '/equipment'
end

get '/muscles' do
  @muscles = @db.all_muscles 

  erb :"muscles/index"
end

get '/muscles/new' do
  erb :'muscles/new'
end

get '/muscles/:id/edit' do
  @muscle_id = params[:id].to_i
  @muscle = @db.find_muscle(@muscle_id).first
  binding.pry

  erb :"muscles/edit"
end

get '/muscles/:id' do
  @muscle_id = params[:id].to_i
  @muscle = @db.find_muscle(@muscle_id).first
  @exercises = @db.get_exercises_for_muscle(@muscle_id)

  erb :"muscles/show"
end

post '/muscles' do
  muscle_name = params[:muscle_name].strip

  if (error = error_for_name(muscle_name))
    session[:error] = error
    erb :"muscles/new"
  else
    result = @db.add_muscle(muscle_name)
  
    if result == "PG::UniqueViolation"
      session[:error] = "#{muscle_name} already exists"
      erb :"muscles/new"
    else
      redirect '/muscles'
    end
  end
end

patch '/muscles/:id' do
  new_name = params[:muscle_name].strip
  muscle_id = params[:id].to_i
  @db.update_muscle(muscle_id, new_name)

  redirect "/muscles/#{muscle_id}"
end

post '/muscles/:id/delete' do
  muscle_id = params[:id].to_i
  @db.delete_muscle(muscle_id)

  redirect '/muscles'
end