require 'sequel'
require 'sequel/extensions/migration'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'fileutils'

DB_URL = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
MIGRATIONS_DIR = 'db/migrations'

namespace :db do
  desc "Create the database files"
  task :create do
    db_path = DB_URL.sub('sqlite://', '')
    dir = File.dirname(db_path)
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    if File.exist?(db_path)
      puts "Database #{db_path} already exists."
    else
      Sequel.connect(DB_URL)
      puts "Created database #{db_path}."
    end
  end

  desc "Drop the database files"
  task :drop do
    db_path = DB_URL.sub('sqlite://', '')
    if File.exist?(db_path)
      File.delete(db_path)
      puts "Dropped database #{db_path}."
    else
      puts "Database #{db_path} does not exist."
    end
  end

  desc "Create, migrate, and seed the database"
  task :setup => [:create, :migrate, :seed]

  desc "Drop and setup the database"
  task :reset => [:drop, :setup]

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

  desc "Seed the database with initial data"
  task :seed do
    $LOAD_PATH.unshift File.expand_path('./lib', __dir__)
    load 'data/seed.rb'
    puts "Database seeded."
  end
end

namespace :schedule do
  desc "Generate schedule (wraps scripts/generate_schedule.rb)"
  task :generate do
    sh "ruby scripts/generate_schedule.rb #{ARGV[1..-1].join(' ')}"
  end
end

namespace :shows do
  desc "Expand shows (wraps scripts/expand_shows.rb)"
  task :expand do
    sh "ruby scripts/expand_shows.rb #{ARGV[1..-1].join(' ')}"
  end
end

desc "Open an IRB console with the app environment loaded"
task :console do
  $LOAD_PATH.unshift File.expand_path('.', __dir__)
  require 'irb'
  require 'silo_night'
  ARGV.clear
  IRB.start
end

desc "List all routes"
task :routes do
  sh "ruby scripts/list_routes.rb"
end

desc "Run RuboCop linting"
task :lint do
  # Ignore the exit code
  sh "bundle exec rubocop || true"
end

desc "Report code statistics (LOC)"
task :stats do
  puts "Code Statistics:"
  dirs = ['lib', 'scripts', 'spec', 'features']
  total_loc = 0
  dirs.each do |dir|
    if Dir.exist?(dir)
      loc = `find #{dir} -name "*.rb" | xargs wc -l`.split("\n").last.to_i rescue 0
      puts "  #{dir}: #{loc} LOC"
      total_loc += loc
    end
  end
  puts "  Total: #{total_loc} LOC"
  
  if Dir.exist?('coverage')
    puts "Coverage data found in /coverage"
  else
    puts "No coverage data found. Run tests with coverage enabled if available."
  end
end

namespace :test do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = "--tag ~failing"
  end

  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.cucumber_opts = "--tags 'not @failing'"
  end
end

desc "Run all tests"
task :test => ['db:migrate', 'test:spec', 'test:cucumber']

task :default => :test
