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

ActiveRecord::Schema[7.0].define(version: 2022_07_19_094504) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "kylas_engine_tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kylas_api_key"
    t.string "webhook_api_key"
    t.bigint "kylas_tenant_id"
    t.string "timezone", default: "Asia/Calcutta"
  end

  create_table "kylas_engine_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "is_tenant", default: false
    t.string "kylas_access_token"
    t.string "kylas_refresh_token"
    t.datetime "kylas_access_token_expires_at"
    t.boolean "active", default: false
    t.bigint "tenant_id"
    t.bigint "kylas_user_id"
    t.index ["confirmation_token"], name: "index_kylas_engine_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_kylas_engine_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_kylas_engine_users_on_reset_password_token", unique: true
    t.index ["tenant_id"], name: "index_kylas_engine_users_on_tenant_id"
  end

  add_foreign_key "kylas_engine_users", "kylas_engine_tenants", column: "tenant_id"
end
