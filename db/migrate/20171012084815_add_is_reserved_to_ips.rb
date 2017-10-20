class AddIsReservedToIps < ActiveRecord::Migration[5.1]
  def change
    add_column :ips, :is_reserved, :boolean
  end
end
