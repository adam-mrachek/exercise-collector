# frozen_string_literal: true

require "sinatra"

require_relative "exercise"
require_relative "equipment"
require_relative "muscle_group"

configure(:development) do
  require 'pry'
  require 'sinatra/reloader'
  also_reload "exercise.rb"
end

before do
  @exercise = Exercise.new(logger)
  @equipment = Equipment.new(logger)
  @muscle_group = MuscleGroup.new(logger)
end

get '/' do
  @exercises = @exercise.all
  erb :index
end

get '/exercises/new' do
  @all_equipment = @equipment.all
  @all_muscle_groups = @muscle_group.all

  erb :new
end

get '/exercises/:id' do
  @exercise_id = params[:id].to_i
  @exercise = @exercise.find(@exercise_id)
  erb :show
end

post '/exercises' do
  exercise_name = params[:exercise_name].strip
  equipment = params[:equipment]
  muscle_groups = params[:muscle_groups]
  new_exercise = @exercise.add(exercise_name)
  binding.pry
  redirect '/'
end
