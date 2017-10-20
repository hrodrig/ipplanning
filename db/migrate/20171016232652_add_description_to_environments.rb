class AddDescriptionToEnvironments < ActiveRecord::Migration[5.1]
  def change
    add_column :environments, :description, :text
  end
end
