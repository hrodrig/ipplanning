class AddUseVlanDescriptorToIps < ActiveRecord::Migration[5.1]
  def change
    add_column :ips, :use_vlan_descriptor, :boolean, null: false, default: true
  end
end
