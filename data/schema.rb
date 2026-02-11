require 'sequel'

db_url = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
db = Sequel.connect(db_url)

db.create_table? :users do
  primary_key :id
  String      :name,       unique: true
  String      :config,     null: true
  String      :schedule,   null: true
end

db.create_table? :shows do
  primary_key :id
  String      :name,        unique: true
  String      :uri_encoded, index: true
  String      :wiki_page,   null: true
  String      :page_title,  null: true
  String      :runtime
end

db.create_table? :shows_users do
  foreign_key  :user_id, :users, null: false
  foreign_key  :show_id, :shows, null: false
  Integer      :show_order
  primary_key  [:show_id, :user_id]
  index        [:show_id, :user_id]
end

