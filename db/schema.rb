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

ActiveRecord::Schema[8.0].define(version: 2026_04_28_123000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_settings", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "value_boolean"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value_type", default: "boolean", null: false
    t.string "value_string"
    t.integer "value_integer"
    t.index ["key"], name: "index_app_settings_on_key", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "assigned_admin_id"
    t.bigint "vehicle_id"
    t.bigint "service_id", null: false
    t.datetime "scheduled_at"
    t.integer "status", default: 0, null: false
    t.text "customer_notes"
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "guest_name"
    t.string "guest_email"
    t.string "guest_phone"
    t.string "guest_vehicle_make"
    t.string "guest_vehicle_model"
    t.integer "guest_vehicle_year"
    t.string "guest_vehicle_license"
    t.string "guest_token"
    t.index ["assigned_admin_id"], name: "index_appointments_on_assigned_admin_id"
    t.index ["customer_id"], name: "index_appointments_on_customer_id"
    t.index ["guest_email"], name: "index_appointments_on_guest_email"
    t.index ["guest_token"], name: "index_appointments_on_guest_token", unique: true
    t.index ["scheduled_at"], name: "index_appointments_on_scheduled_at"
    t.index ["service_id"], name: "index_appointments_on_service_id"
    t.index ["status"], name: "index_appointments_on_status"
    t.index ["vehicle_id"], name: "index_appointments_on_vehicle_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "duration_minutes", null: false
    t.decimal "price", precision: 8, scale: 2
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "phone_number"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "make", null: false
    t.string "model", null: false
    t.integer "year", null: false
    t.string "license_plate", null: false
    t.string "vin"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_plate"], name: "index_vehicles_on_license_plate", unique: true
    t.index ["user_id"], name: "index_vehicles_on_user_id"
    t.index ["vin"], name: "index_vehicles_on_vin", unique: true, where: "(vin IS NOT NULL)"
  end

  add_foreign_key "appointments", "services"
  add_foreign_key "appointments", "users", column: "assigned_admin_id"
  add_foreign_key "appointments", "users", column: "customer_id"
  add_foreign_key "appointments", "vehicles"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "vehicles", "users"
end
