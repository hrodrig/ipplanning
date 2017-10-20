class AddMemorySizeToHosts < ActiveRecord::Migration[5.1]
  def change
    add_column :hosts, :memory_size, :integer
  end
end
