class AddDescriptorToVlans < ActiveRecord::Migration[5.1]
  def change
    add_column :vlans, :descriptor, :string
  end
end
