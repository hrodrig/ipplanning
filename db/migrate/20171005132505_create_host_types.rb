class CreateHostTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :host_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :host_types, :name
  end
end
