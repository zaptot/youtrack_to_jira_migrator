class MakeOnlyProjectSyncable < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :state, :string

    remove_column :jira_users, :state
    remove_column :attachments, :state
    remove_column :comments, :state
    remove_column :issues, :state
    remove_column :links, :state
  end
end
