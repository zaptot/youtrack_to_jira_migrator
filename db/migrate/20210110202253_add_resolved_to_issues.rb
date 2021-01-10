class AddResolvedToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :resolved, :boolean
  end
end
