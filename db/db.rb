# frozen_string_literal: true

require 'logger'
require 'sequel'

# Get the environment, default to production
type = ENV.fetch('APP_ENV', 'production')

# find db path
db_path = File.dirname(__FILE__)
db = "#{db_path}/#{type}.sqlite"

# find log path
log_path = "#{File.dirname(__FILE__)}/../logs/"
log = "#{log_path}/#{type}.log"

# If the log directory does not exist we create it
Dir.mkdir(log_path) unless File.exist?(log_path)

# Connect to our database
Db = Sequel.sqlite(db, logger: Logger.new(log))
