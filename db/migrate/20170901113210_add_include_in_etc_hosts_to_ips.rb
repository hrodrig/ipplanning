class AddIncludeInEtcHostsToIps < ActiveRecord::Migration[5.1]
  def change
    add_column :ips, :include_in_etc_hosts, :boolean, null: false, default: true
  end
end
