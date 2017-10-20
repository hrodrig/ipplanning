class CreateVlans < ActiveRecord::Migration[5.1]
  def change
    create_table :vlans do |t|
      t.integer :number
      t.text :name
      t.string :network
      t.integer :netmask
      t.string :gateway
      t.text :notes

      t.timestamps
    end
    add_index :vlans, :number, unique: true
  end
end
