require "sequel"

db_path = ENV.fetch("DATABASE_PATH", File.join(__dir__, "..", "db", "linknote.sqlite3"))
DB = Sequel.sqlite(db_path)

Sequel.extension :migration
Sequel::Migrator.run(DB, File.join(__dir__, "..", "db", "migrations"))

Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :validation_helpers