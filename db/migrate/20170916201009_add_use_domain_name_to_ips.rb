class AddUseDomainNameToIps < ActiveRecord::Migration[5.1]
  def change
    add_column :ips, :use_domain_name, :boolean, null: false, default: true
  end
end
