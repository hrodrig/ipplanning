class AddTypeToHosts < ActiveRecord::Migration[5.1]
  def change
    # Virtual Host, Standalone, Hypervisor
    add_column :hosts, :hosts_type, :string, null: false, default: 'Virtual Host'
  end
end
