class CreateExternalips < ActiveRecord::Migration[5.1]
  def change
    create_table :externalips do |t|
      t.string :address, null: false
      t.string :hostname, null: false
      t.string :notes
      t.boolean :include_in_etc_hosts, null: false, default: true

      t.timestamps
    end
    add_index :externalips, [:address, :hostname], unique: true
    add_index :externalips, :hostname
  end
end
