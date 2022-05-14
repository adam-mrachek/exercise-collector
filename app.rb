# frozen_string_literal: true

require "sinatra"
require "bcrypt"
require "securerandom"

require_relative "database_persistence"

configure do
  enable :sessions
  set :sessions_secret, SecureRandom.hex(64)
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

helpers do
  def signed_in?
    session.key?(:username)
  end
end

def error_for_name(name)
  if !(1..100).cover?(name.size)
    "Name must be between 1 and 100 characters."
  end
end

def require_valid_username(username)
  if username.length < 4
    session[:error] = "Username must contain at least 4 characters."
    redirect '/accounts/new'
  end
end

def require_valid_password(password)
  if password.length < 8
    session[:error] = "Password must contain at least 8 characters."
    redirect '/accounts/new'
  end
end

def require_sign_in
  unless signed_in?
    session[:error] = "You must be signed in to do that."
    redirect '/'
  end
end

def login(username, password)
  account = @db.find_account_by_name(username).first

  if BCrypt::Password.new(account["password"]) == password
    session[:username] = account["name"]
    session[:success] = "You have been signed in."
    redirect '/'
  else
    session[:error] = "Invalid username and/or password."
    redirect '/accounts/signin'
  end
end

get '/' do
  if signed_in?
    redirect '/exercises'
  end

  erb :index
end

get '/accounts/signin' do
  erb :"accounts/signin"
end

get '/accounts/new' do
  erb :"accounts/new"
end

get '/accounts/:id' do
  require_sign_in

  @account_id = params[:id].to_i
  erb :"accounts/show"
end

post '/accounts' do
  require_valid_username(params[:username].strip)
  require_valid_password(params[:password].strip)

  @account_name = params[:username]
  @password = params[:password]
  account = @db.create_account(@account_name, @password)

  session[:success] = "Account successfully created!"
  redirect '/'
end

post '/accounts/signin' do
  @account_name = params[:username]
  @password = params[:password]

  login(@account_name, @password)
end

post '/accounts/signout' do
  session.delete(:username)
  session[:success] = "You have been signed out."
  redirect '/'
end

get '/exercises' do
  require_sign_in

  @exercises = @db.all_exercises
  erb :"exercises/index"
end

get '/exercises/new' do
  require_sign_in

  @all_equipment = @db.all_equipment
  @all_muscle_groups = @db.all_muscles

  erb :"exercises/new"
end

get '/exercises/:id' do
  require_sign_in

  @exercise_id = params[:id].to_i
  @exercise = @db.find_exercise(@exercise_id)
  @muscle_groups = @db.exercise_muscle_groups(@exercise_id)
  @equipment = @db.get_equipment_for_exercises(@exercise_id)

  erb :"exercises/show"
end

get '/exercises/:id/edit' do
  require_sign_in

  @exercise_id = params[:id].to_i
  @exercise = @db.find_exercise(@exercise_id)
  erb :"exercises/edit"
end

post '/exercises' do
  require_sign_in

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
      exercise_id = result.first["id"].to_i
      @db.add_equipment_exercises(exercise_id, equipment_ids)
      @db.add_muscle_groups_exercises(exercise_id, muscle_group_ids)
      redirect '/'
    end
  end
end

patch '/exercises/:id' do
  require_sign_in

  exercise_name = params[:exercise_name].strip
  exercise_id = params[:id].to_i
  @db.update_exercise(exercise_id, exercise_name)

  redirect "/exercises/#{exercise_id}"
end

post '/exercises/:id/delete' do
  require_sign_in

  exercise_id = params[:id]
  @db.delete_exercise(exercise_id)

  redirect '/'
end

get '/equipment' do
  require_sign_in

  @equipment = @db.all_equipment

  erb :"equipment/index"
end

get '/equipment/new' do
  require_sign_in
  erb :"equipment/new"
end

get '/equipment/:id/edit' do
  require_sign_in

  equipment_id = params[:id].to_i
  @equipment = @db.find_equipment(equipment_id).first

  erb :"equipment/edit"
end

get '/equipment/:id' do
  require_sign_in

  @equipment_id = params[:id].to_i
  @equipment = @db.find_equipment(@equipment_id).first
  @exercises = @db.get_exercises_for_equipment(@equipment_id)

  erb :"equipment/show"
end

post '/equipment' do
  require_sign_in

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
  require_sign_in

  new_name = params[:equipment_name].strip
  equipment_id = params[:id].to_i
  @db.update_equipment(equipment_id, new_name)

  redirect "/equipment/#{equipment_id}"
end

post '/equipment/:id/delete' do
  require_sign_in

  equipment_id = params[:id].to_i
  @db.delete_equipment(equipment_id)

  redirect '/equipment'
end

get '/muscles' do
  require_sign_in

  @muscles = @db.all_muscles 

  erb :"muscles/index"
end

get '/muscles/new' do
  require_sign_in

  erb :'muscles/new'
end

get '/muscles/:id/edit' do
  require_sign_in

  @muscle_id = params[:id].to_i
  @muscle = @db.find_muscle(@muscle_id).first
  binding.pry

  erb :"muscles/edit"
end

get '/muscles/:id' do
  require_sign_in

  @muscle_id = params[:id].to_i
  @muscle = @db.find_muscle(@muscle_id).first
  @exercises = @db.get_exercises_for_muscle(@muscle_id)

  erb :"muscles/show"
end

post '/muscles' do
  require_sign_in

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
  require_sign_in

  new_name = params[:muscle_name].strip
  muscle_id = params[:id].to_i
  @db.update_muscle(muscle_id, new_name)

  redirect "/muscles/#{muscle_id}"
end

post '/muscles/:id/delete' do
  require_sign_in

  muscle_id = params[:id].to_i
  @db.delete_muscle(muscle_id)

  redirect '/muscles'
end