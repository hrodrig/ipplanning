json.extract! server_rack, :id, :location_id, :name, :u_height, :notes, :created_at, :updated_at
json.photos_count server_rack.photos.count
json.url server_rack_url(server_rack, format: :json)
