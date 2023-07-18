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

ActiveRecord::Schema[7.0].define(version: 2023_07_17_233419) do
  create_table "autonomous_assignment_events", force: :cascade do |t|
    t.integer "autonomous_assignment_id", null: false
    t.string "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["autonomous_assignment_id"], name: "index_autonomous_assignment_events_on_autonomous_assignment_id"
  end

  create_table "autonomous_assignments", force: :cascade do |t|
    t.string "name"
    t.string "arguments"
    t.integer "codebase_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codebase_id"], name: "index_autonomous_assignments_on_codebase_id"
  end

  create_table "codebases", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "checked_out", default: false
    t.string "name_slug"
    t.string "github_app_installation_id"
    t.string "github_app_issue_id"
    t.string "context"
    t.index ["name_slug"], name: "index_codebases_on_name_slug", unique: true
  end

  create_table "github_access_tokens", force: :cascade do |t|
    t.integer "codebase_id", null: false
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codebase_id"], name: "index_github_access_tokens_on_codebase_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "description"
    t.string "script"
    t.datetime "started_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.integer "exit_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "autonomous_assignment_events", "autonomous_assignments"
  add_foreign_key "autonomous_assignments", "codebases"
  add_foreign_key "github_access_tokens", "codebases"
end
