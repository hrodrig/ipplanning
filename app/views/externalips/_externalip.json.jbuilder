json.extract! externalip, :id, :address, :hostname, :notes, :include_in_etc_hosts, :created_at, :updated_at
json.url externalip_url(externalip, format: :json)
