json.extract! setting, :id, :name, :description, :created_at, :updated_at
json.value setting_value_for_json(setting)
json.url setting_url(setting, format: :json)
