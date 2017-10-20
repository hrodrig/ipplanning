json.extract! vlan, :id, :number, :name, :network, :netmask, :gateway, :notes, :created_at, :updated_at
json.url vlan_url(vlan, format: :json)
