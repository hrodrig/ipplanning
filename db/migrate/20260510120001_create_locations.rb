# frozen_string_literal: true

# Idempotent: the table may already exist if a previous attempt failed before
# recording the version in schema_migrations (e.g. after fixing migration timestamps).
class CreateLocations < ActiveRecord::Migration[8.0]
  def up
    unless table_exists?(:locations)
      create_table :locations do |t|
        t.string :name, null: false
        t.text :description

        t.timestamps
      end
    end

    return if index_exists?(:locations, :name, name: "index_locations_on_name")

    add_index :locations, :name, unique: true, name: "index_locations_on_name"
  end

  def down
    drop_table :locations if table_exists?(:locations)
  end
end
