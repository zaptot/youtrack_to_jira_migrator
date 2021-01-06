class AddUniqIndexOnComments < ActiveRecord::Migration[6.0]
  def change
    add_index :comments, [:project_id, :issue_id, :jira_user_id, :created_at], unique: true, name: 'uniq_comments_index'
  end
end
