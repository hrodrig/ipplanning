class AddDescriptionToHostTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :host_types, :description, :text
  end
end
