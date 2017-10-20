class CreateHosts < ActiveRecord::Migration[5.1]
  def change
    create_table :hosts do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :hosts, :name, unique: true

    create_table :hosts_ips, :id => false do |t|
      t.integer :host_id
      t.integer :ip_id
    end
    add_index :hosts_ips, [:host_id, :ip_id], unique: true
  end
end
