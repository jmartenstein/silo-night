require 'sequel'
require 'sequel/extensions/migration'

DB_URL = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
MIGRATIONS_DIR = 'db/migrations'

namespace :db do
  desc "Run migrations to the latest version"
  task :migrate do
    DB = Sequel.connect(DB_URL)
    Sequel::Migrator.run(DB, MIGRATIONS_DIR)
    puts "Applied migrations to the latest version."
  end

  desc "Rollback the last migration"
  task :rollback do
    DB = Sequel.connect(DB_URL)
    current_version = DB[:schema_info].first[:version] rescue 0
    target = current_version > 0 ? current_version - 1 : 0
    Sequel::Migrator.run(DB, MIGRATIONS_DIR, target: target)
    puts "Rolled back to version #{target}."
  end

  desc "Show current migration version"
  task :version do
    DB = Sequel.connect(DB_URL)
    version = DB[:schema_info].first[:version] rescue 0
    puts "Current migration version: #{version}"
  end

  desc "Check if migrations are current"
  task :status do
    DB = Sequel.connect(DB_URL)
    if Sequel::Migrator.is_current?(DB, MIGRATIONS_DIR)
      puts "Migrations are up to date."
    else
      puts "Migrations are NOT up to date."
      exit 1
    end
  end
end
