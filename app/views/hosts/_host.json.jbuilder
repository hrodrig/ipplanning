json.extract! host, :id, :name, :description, :created_at, :updated_at,
  :deployment_form, :server_rack_id, :rack_units, :rack_position_start
json.url host_url(host, format: :json)
