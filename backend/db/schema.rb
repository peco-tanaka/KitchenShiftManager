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

ActiveRecord::Schema[7.2].define(version: 2025_07_04_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "employee_number", null: false, comment: "社員番号（4桁）"
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false, comment: "ロール: 0=employee, 1=manager"
    t.integer "hourly_wage", null: false, comment: "時給（円）"
    t.date "hired_on", null: false, comment: "入社日"
    t.date "terminated_on", comment: "退職日"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name", limit: 50, null: false
    t.string "first_name", limit: 50, null: false
    t.index ["employee_number"], name: "index_users_on_employee_number", unique: true
    t.index ["role"], name: "index_users_on_role"
  end
end
