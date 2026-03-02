require 'sequel'
require 'sequel/extensions/migration'
require 'dotenv'
Dotenv.load(".env.#{ENV['RACK_ENV'] || 'development'}", ".env")

DB_URL = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
DB = Sequel.connect(DB_URL)
