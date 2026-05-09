# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_05_10_120003) do
  create_table "active_storage_attachments", charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admins", charset: "utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "environments", charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name"], name: "index_environments_on_name", unique: true
  end

  create_table "externalips", charset: "utf8", force: :cascade do |t|
    t.string "address", null: false
    t.string "hostname", null: false
    t.string "notes"
    t.boolean "include_in_etc_hosts", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_hostname"
    t.index ["address", "hostname"], name: "index_externalips_on_address_and_hostname", unique: true
    t.index ["hostname"], name: "index_externalips_on_hostname"
  end

  create_table "host_types", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name"], name: "index_host_types_on_name"
  end

  create_table "hosts", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hosts_type", default: "Virtual Host", null: false
    t.bigint "environment_id"
    t.integer "memory_size"
    t.integer "total_sockets"
    t.integer "total_vcpus"
    t.bigint "infrastructure_id"
    t.bigint "host_type_id"
    t.index ["environment_id"], name: "index_hosts_on_environment_id"
    t.index ["host_type_id"], name: "index_hosts_on_host_type_id"
    t.index ["infrastructure_id"], name: "index_hosts_on_infrastructure_id"
    t.index ["name"], name: "index_hosts_on_name", unique: true
  end

  create_table "hosts_ips", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "host_id"
    t.integer "ip_id"
    t.index ["host_id", "ip_id"], name: "index_hosts_ips_on_host_id_and_ip_id", unique: true
  end

  create_table "infrastructures", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name"], name: "index_infrastructures_on_name", unique: true
  end

  create_table "ips", charset: "utf8", force: :cascade do |t|
    t.integer "vlan_id"
    t.string "address"
    t.text "notes"
    t.string "background_color"
    t.string "text_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "include_in_etc_hosts", default: true, null: false
    t.boolean "use_vlan_descriptor", default: true, null: false
    t.string "hostname_alias"
    t.boolean "use_domain_name", default: true, null: false
    t.boolean "is_reserved"
    t.string "complete_hostname_alias"
    t.index ["address"], name: "index_ips_on_address", unique: true
    t.index ["hostname_alias"], name: "index_ips_on_hostname_alias"
    t.index ["vlan_id"], name: "index_ips_on_vlan_id"
  end

  create_table "locations", charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_locations_on_name", unique: true
  end

  create_table "server_racks", charset: "utf8", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.string "name", null: false
    t.integer "u_height"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id", "name"], name: "index_server_racks_on_location_id_and_name", unique: true
    t.index ["location_id"], name: "index_server_racks_on_location_id"
  end

  create_table "settings", charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "value"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

  create_table "users", charset: "utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vlans", charset: "utf8", force: :cascade do |t|
    t.integer "number"
    t.text "name"
    t.string "network"
    t.integer "netmask"
    t.string "gateway"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "descriptor"
    t.boolean "include_in_etc_hosts", default: true
    t.index ["number"], name: "index_vlans_on_number", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "hosts", "environments"
  add_foreign_key "hosts", "host_types"
  add_foreign_key "hosts", "infrastructures"
  add_foreign_key "server_racks", "locations"
end
