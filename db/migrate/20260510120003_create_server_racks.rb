# frozen_string_literal: true

class CreateServerRacks < ActiveRecord::Migration[8.0]
  def change
    create_table :server_racks do |t|
      t.references :location, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :u_height
      t.text :notes

      t.timestamps
    end

    add_index :server_racks, [:location_id, :name], unique: true, name: "index_server_racks_on_location_id_and_name"
  end
end
