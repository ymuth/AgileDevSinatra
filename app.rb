# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'require_all'

enable :sessions

require_rel 'db/db', 'models', 'controllers'
