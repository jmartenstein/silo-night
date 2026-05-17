Sequel.migration do
  change do
    alter_table(:shows) do
      rename_column :runtime, :deprecated_runtime
      rename_column :poster_path, :deprecated_poster_path
    end
  end
end
