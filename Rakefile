require 'json'
require 'yaml'
require 'erb'
require 'logger'
require 'sinatra/activerecord/rake'

require "bundler/gem_tasks"

desc "Setup the database connection environment"
task :environment do
  ENV['RACK_ENV'] ||= 'production'
  rack_env = ENV['RACK_ENV']

  # Make sure heroku logging works
  STDOUT.sync = true
  STDERR.sync = true
  logger = Logger.new(STDOUT)

  # Configure the ActiveRecord library to use heroku compatible STDERR logging.
  ActiveRecord::Base.logger = logger.clone

  # Heroku overwrites our database.yml file with an ERB tempalte which
  # populates the database connection information automatically.  We need to
  # make sure to parse the file as ERB and not YAML directly.
  dbconfig = YAML.load(ERB.new(File.read('config/database.yml')).result)
  logger.debug("config/database.yml is #{JSON.generate(dbconfig)}")

  # establish_connection is what actually connects to the database server.
  ActiveRecord::Base.establish_connection(dbconfig[rack_env])
end

namespace :db do
  # This will use the migration as implemented in ActiveRecordTasks
  task :migrate => :environment
end
