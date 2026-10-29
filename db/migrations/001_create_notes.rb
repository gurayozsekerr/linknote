Sequel.migration do
  change do
    create_table(:notes) do
      primary_key :id
      String :title, null: false
      String :body, text: true
      DateTime :created_at
      DateTime :updated_at
    end
  end
end