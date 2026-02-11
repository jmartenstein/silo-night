Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String      :name,       unique: true
      String      :config,     text: true
      String      :schedule,   text: true
    end

    create_table(:shows) do
      primary_key :id
      String      :name,        unique: true
      String      :uri_encoded, index: true
      String      :wiki_page,   text: true
      String      :page_title,  text: true
      String      :runtime
    end

    create_table(:shows_users) do
      foreign_key  :user_id, :users, null: false
      foreign_key  :show_id, :shows, null: false
      Integer      :show_order
      primary_key  [:show_id, :user_id]
    end
  end
end
