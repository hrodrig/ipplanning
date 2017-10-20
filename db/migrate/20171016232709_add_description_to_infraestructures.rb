class AddDescriptionToInfraestructures < ActiveRecord::Migration[5.1]
  def change
    add_column :infraestructures, :description, :text
  end
end
