class AddIncludeInEtcHostsToVlans < ActiveRecord::Migration[5.1]
  def change
    add_column :vlans, :include_in_etc_hosts, :boolean, default: true
  end
end
