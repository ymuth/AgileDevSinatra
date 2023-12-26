# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end
SimpleCov.coverage_dir 'coverage'

ENV['APP_ENV'] = 'dev' # Environment variable so we're using test database

require 'require_all'
require 'rack/test'
require_relative '../app'
require 'capybara/rspec'
Capybara.app = Sinatra::Application

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods
end

# clear out the database
def clear_database
  Db.from('messages').delete
  Db.from('users').delete
  Db.from('profiles').delete
  Db.from('courses').delete
  Db.from('course_progress').delete
  Db.from('suspended_users').delete
  Db.from('user_tokens').delete
  Db.from('course_approval_queue').delete
end

# ensure we're always starting from a clean database
clear_database

# Can be used to create a test user
def create_user
  user = User.new
  user.username = 'test'
  user.password_hash = 'password123'
  user.email = 'test@emailx.com'
  user.permission_level = 0
  user.save_changes

  profile = Profile.new
  profile.first_name = 'Test'
  profile.last_name = 'Account'
  profile.course_level = 0
  profile.year = 0
  profile.user_id = user.user_id
  profile.save_changes

  user.user_id
end

def create_user_2
  user = User.new
  user.username = 'test2'
  user.password = 'password1234'
  user.email = 'test@emailx.com'
  user.permission_level = 0
  user.save_changes

  profile = Profile.new
  profile.first_name = 'Test'
  profile.last_name = 'Account'
  profile.course_level = 0
  profile.year = 0
  profile.user_id = user.user_id
  profile.save_changes
  user.user_id
end

def create_user_with_permission(username, password, permission)
  user = User.new
  user.username = username
  user.password_hash = password
  user.email = 'test@emailx.com'
  user.permission_level = permission
  user.save_changes

  profile = Profile.new
  profile.first_name = 'Test'
  profile.last_name = 'Account'
  profile.course_level = 0
  profile.year = 0
  profile.user_id = user.user_id
  profile.save_changes
  user.user_id
end

# Used for testing the different capabilities of logged in/logged out user
def login_user(username, password)
  visit '/login'
  fill_in 'username', with: username
  fill_in 'password', with: password
  click_button 'Login'
end

def current_user
  @user ||= User.find(session[:user_id]) if session[:user_id]
end
