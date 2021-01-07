class AddWorkflowNameToProject < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :workflow_name, :string
  end
end
