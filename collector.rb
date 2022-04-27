# frozen_string_literal: true

require "sinatra"

require_relative "exercise"

configure(:development) do
  require 'pry'
  require 'sinatra/reloader'
  also_reload "exercise.rb"
end

before do
  @storage = Exercise.new(logger)
end

get '/' do
  @exercises = @storage.all_exercises
  erb :index
end

get '/exercises/new' do
  erb :new
end

get '/exercises/:id' do
  @exercise_id = params[:id].to_i
  @exercise = @storage.find_exercise(@exercise_id)
  erb :show
end

post '/exercises' do
  exercise_name = params[:exercise_name].strip
  @storage.add_exercise(exercise_name)

  redirect '/'
end
