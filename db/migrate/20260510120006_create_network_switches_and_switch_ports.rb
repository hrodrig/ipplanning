# frozen_string_literal: true

class CreateNetworkSwitchesAndSwitchPorts < ActiveRecord::Migration[8.0]
  def change
    create_table :network_switches do |t|
      t.string :name, null: false
      t.string :serial
      t.string :equipment_model
      t.text :notes
      t.string :firmware_version
      t.date :firmware_updated_on
      t.string :management_username
      t.text :management_secret_hint
      t.references :server_rack, foreign_key: true
      t.integer :rack_position_start
      t.integer :rack_units
      t.string :pdu_reference
      t.string :outlet_reference

      t.timestamps
    end

    add_index :network_switches, :name, unique: true

    create_table :switch_ports do |t|
      t.references :network_switch, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :switch_ports, [:network_switch_id, :name], unique: true
  end
end
