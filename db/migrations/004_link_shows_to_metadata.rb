Sequel.migration do
  change do
    alter_table(:show_metadata) do
      add_foreign_key :show_id, :shows, null: true
    end
  end
end
