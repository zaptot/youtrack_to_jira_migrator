class AddJiraUrlToProject < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :jira_url, :string
  end
end
