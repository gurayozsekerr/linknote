Sequel.migration do
  change do
    create_table(:links) do
      primary_key :id
      String :code, null: false, unique: true
      String :url, null: false, text: true
      Integer :clicks, null: false, default: 0
      foreign_key :note_id, :notes, null: true, on_delete: :set_null
      DateTime :created_at
      DateTime :updated_at
    end
  end
end