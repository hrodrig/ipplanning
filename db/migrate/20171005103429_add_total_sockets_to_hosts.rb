class AddTotalSocketsToHosts < ActiveRecord::Migration[5.1]
  def change
    add_column :hosts, :total_sockets, :integer
  end
end
