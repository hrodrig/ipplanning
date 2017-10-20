class CreateInfraestructures < ActiveRecord::Migration[5.1]
  def change
    create_table :infraestructures do |t|
      t.string :name

      t.timestamps
    end
    add_index :infraestructures, :name, unique: true
  end
end
