Sequel.migration do
  change do
    alter_table(:shows) do
      add_column :poster_path, String
    end
  end
end
