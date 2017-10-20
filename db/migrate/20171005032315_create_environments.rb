class CreateEnvironments < ActiveRecord::Migration[5.1]
  def change
    create_table :environments do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :environments, :name, unique: true
  end
end
