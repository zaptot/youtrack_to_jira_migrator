class AddVotersAndWatchersToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :voters, :string, array: true
    add_column :issues, :watchers, :string, array: true
  end
end
