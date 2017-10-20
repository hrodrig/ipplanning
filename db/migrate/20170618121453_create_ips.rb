class CreateIps < ActiveRecord::Migration[5.1]
  def change
    create_table :ips do |t|
      t.references :vlan, foreign_key: true
      t.string :address
      t.text :notes
      t.string :background_color
      t.string :text_color

      t.timestamps
    end
    add_index :ips, :address, unique: true
  end
end
