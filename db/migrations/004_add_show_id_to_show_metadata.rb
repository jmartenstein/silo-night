Sequel.migration do
  change do
    alter_table(:show_metadata) do
      add_foreign_key :show_id, :shows, index: true
    end
  end
end
