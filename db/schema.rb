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

ActiveRecord::Schema.define(version: 2021_01_10_175354) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.bigint "comment_id"
    t.bigint "issue_id"
    t.string "url"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "project_id"
    t.index ["comment_id"], name: "index_attachments_on_comment_id"
    t.index ["issue_id", "name"], name: "index_attachments_on_issue_id_and_name", unique: true
    t.index ["issue_id"], name: "index_attachments_on_issue_id"
    t.index ["project_id"], name: "index_attachments_on_project_id"
    t.index ["url"], name: "index_attachments_on_url"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "jira_user_id", null: false
    t.string "project_id"
    t.bigint "issue_id", null: false
    t.index ["issue_id"], name: "index_comments_on_issue_id"
    t.index ["jira_user_id"], name: "index_comments_on_jira_user_id"
    t.index ["project_id", "issue_id", "jira_user_id", "created_at"], name: "uniq_comments_index", unique: true
    t.index ["project_id"], name: "index_comments_on_project_id"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "number_in_project", null: false
    t.string "title", null: false
    t.text "description"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "project_id"
    t.string "full_name"
    t.index ["project_id", "email"], name: "index_jira_users_on_project_id_and_email", unique: true
  end

  create_table "links", force: :cascade do |t|
    t.string "type"
    t.bigint "issue_from_id"
    t.bigint "issue_to_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "project_from_id"
    t.string "project_to_id"
    t.index ["issue_from_id"], name: "index_links_on_issue_from_id"
    t.index ["issue_to_id"], name: "index_links_on_issue_to_id"
    t.index ["project_from_id"], name: "index_links_on_project_from_id"
    t.index ["type", "issue_from_id", "issue_to_id"], name: "index_links_on_type_and_issue_from_id_and_issue_to_id", unique: true
  end

  create_table "projects", id: :string, force: :cascade do |t|
    t.string "full_name", null: false
    t.string "youtrack_token", null: false
    t.string "youtrack_url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "workflow_name"
    t.string "state"
    t.index ["id"], name: "index_projects_on_id"
  end

  create_table "worklogs", force: :cascade do |t|
    t.string "text"
    t.datetime "date", null: false
    t.integer "duration"
    t.string "project_id", null: false
    t.bigint "jira_user_id"
    t.bigint "issue_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_worklogs_on_issue_id"
    t.index ["jira_user_id"], name: "index_worklogs_on_jira_user_id"
    t.index ["project_id"], name: "index_worklogs_on_project_id"
  end

end
