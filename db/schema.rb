# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171018031438) do

  create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "environments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name"], name: "index_environments_on_name", unique: true
  end

  create_table "externalips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "host_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name"], name: "index_host_types_on_name"
  end

  create_table "hosts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hosts_type", default: "Virtual Host", null: false
    t.bigint "environment_id"
    t.integer "memory_size"
    t.integer "total_sockets"
    t.integer "total_vcpus"
    t.bigint "infraestructure_id"
    t.bigint "host_type_id"
    t.index ["environment_id"], name: "index_hosts_on_environment_id"
    t.index ["host_type_id"], name: "index_hosts_on_host_type_id"
    t.index ["infraestructure_id"], name: "index_hosts_on_infraestructure_id"
    t.index ["name"], name: "index_hosts_on_name", unique: true
  end

  create_table "hosts_ips", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "host_id"
    t.integer "ip_id"
    t.index ["host_id", "ip_id"], name: "index_hosts_ips_on_host_id_and_ip_id", unique: true
  end

  create_table "infraestructures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name"], name: "index_infraestructures_on_name", unique: true
  end

  create_table "ips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "value"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "vlans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  add_foreign_key "hosts", "environments"
  add_foreign_key "hosts", "host_types"
  add_foreign_key "hosts", "infraestructures"
end
