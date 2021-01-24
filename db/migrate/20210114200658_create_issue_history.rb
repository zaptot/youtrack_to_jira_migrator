class CreateIssueHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :issue_histories do |t|
      t.references :jira_user, null: false
      t.references :issue, null: false
      t.string :project_id, null: false, index: true
      t.string :field_name, null: false
      t.string :field_type, null: false
      t.string :from_string
      t.string :to_string

      t.timestamps
    end
  end
end
