class AddCompleteHostnameAliasToIps < ActiveRecord::Migration[5.1]
  def change
    add_column :ips, :complete_hostname_alias, :string
  end
end
