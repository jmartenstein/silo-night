require 'sequel'

db = Sequel.connect('sqlite://data/silo_night.db')

db.create_table :shows do
  primary_key :id
  String      :name
  String      :wiki_page
  String      :page_title
  String      :runtime
end

db.create_table :users do
  primary_key :id
  String      :name
end

db.create_table :usershows do
  primary_key :id
  Integer     :user_id
  Integer     :show_id
end

