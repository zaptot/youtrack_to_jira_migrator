class AddProjectToNeededTables < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :project_id, :string
    add_column :jira_users, :project_id, :string
    add_reference :comments, :project, type: :string

    add_index :issues, %i[project_id number_in_project], unique: true
    add_index :jira_users, %i[project_id email], unique: true
  end
end
