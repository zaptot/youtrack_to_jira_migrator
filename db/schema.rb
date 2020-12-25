# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_22_224353) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.string "reference_type"
    t.bigint "reference_id"
    t.string "url"
    t.string "name"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reference_type", "reference_id"], name: "index_attachments_on_reference_type_and_reference_id"
    t.index ["url"], name: "index_attachments_on_url"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "jira_user_id", null: false
    t.bigint "issue_id", null: false
    t.index ["issue_id"], name: "index_comments_on_issue_id"
    t.index ["jira_user_id"], name: "index_comments_on_jira_user_id"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "number_in_project", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.string "state", null: false
    t.string "tags", default: [], array: true
    t.jsonb "custom_fields", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "jira_user_id", null: false
    t.string "project_id"
    t.index ["jira_user_id"], name: "index_issues_on_jira_user_id"
    t.index ["number_in_project"], name: "index_issues_on_number_in_project"
    t.index ["project_id", "number_in_project"], name: "index_issues_on_project_id_and_number_in_project", unique: true
  end

  create_table "jira_users", force: :cascade do |t|
    t.string "email"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "project_id"
    t.index ["project_id", "email"], name: "index_jira_users_on_project_id_and_email", unique: true
  end

  create_table "links", force: :cascade do |t|
    t.string "type"
    t.bigint "issue_from_id"
    t.bigint "issue_to_id"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_from_id"], name: "index_links_on_issue_from_id"
    t.index ["issue_to_id"], name: "index_links_on_issue_to_id"
    t.index ["type", "issue_from_id", "issue_to_id"], name: "index_links_on_type_and_issue_from_id_and_issue_to_id", unique: true
  end

  create_table "projects", id: :string, force: :cascade do |t|
    t.string "full_name", null: false
    t.string "youtrack_token", null: false
    t.string "youtrack_url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["id"], name: "index_projects_on_id"
  end

end
