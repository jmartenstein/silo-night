require 'sequel'

db = Sequel.connect('sqlite://data/silo_night.db')

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
  primary_key :id
  foreign_key  :user_id, :users, key: :id
  foreign_key  :show_id, :shows, key: :id
end

