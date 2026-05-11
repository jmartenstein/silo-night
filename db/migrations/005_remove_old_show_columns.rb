Sequel.migration do
  change do
    alter_table(:shows) do
      drop_column :wiki_page
      drop_column :page_title
      drop_column :runtime
      drop_column :poster_path
    end
  end
end
