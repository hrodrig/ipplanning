# frozen_string_literal: true

class AddIsDefaultGatewayToIps < ActiveRecord::Migration[8.0]
  def up
    add_column :ips, :is_default_gateway, :boolean, default: false, null: false

    Vlan.find_each do |vlan|
      next if vlan.gateway.blank?

      vlan.ips.where(address: vlan.gateway.to_s.strip).limit(1).update_all(is_default_gateway: true)
    end
  end

  def down
    remove_column :ips, :is_default_gateway
  end
end
