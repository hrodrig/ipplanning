# frozen_string_literal: true

class CreateHostPortsAndPatchConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :host_ports do |t|
      t.references :host, null: false, foreign_key: true
      t.string :name, null: false
      t.string :port_kind, null: false, default: "physical"
      t.string :mac_address
      t.text :notes

      t.timestamps
    end

    add_index :host_ports, [:host_id, :name], unique: true

    create_table :patch_connections do |t|
      t.references :host_port, null: false, foreign_key: true, index: { unique: true }
      t.references :switch_port, null: false, foreign_key: true, index: { unique: true }
      t.string :label
      t.string :cable_color
      t.date :installed_on
      t.text :notes

      t.timestamps
    end
  end
end
