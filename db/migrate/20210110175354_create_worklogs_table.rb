class CreateWorklogsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :worklogs do |t|
      t.string :text
      t.datetime :date, null: false
      t.integer :duration
      t.string :project_id, null: false, index: true
      t.references :jira_user
      t.references :issue

      t.timestamps
    end
  end
end
