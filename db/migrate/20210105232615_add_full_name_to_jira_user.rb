class AddFullNameToJiraUser < ActiveRecord::Migration[6.0]
  def change
    add_column :jira_users, :full_name, :string
  end
end
