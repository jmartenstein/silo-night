Sequel.migration do
  change do
    create_table(:show_metadata) do
      primary_key :id
      String      :provider_name, null: false
      String      :external_id,   null: false
      String      :payload,       text: true
      DateTime    :created_at
      DateTime    :updated_at

      index [:provider_name, :external_id], unique: true
    end
  end
end
