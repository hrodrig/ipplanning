class AddHostnameAliasToIps < ActiveRecord::Migration[5.1]
  def change
    add_column :ips, :hostname_alias, :string
    add_index :ips, :hostname_alias
  end
end
