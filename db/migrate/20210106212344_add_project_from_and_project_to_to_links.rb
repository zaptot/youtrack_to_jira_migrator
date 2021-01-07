class AddProjectFromAndProjectToToLinks < ActiveRecord::Migration[6.0]
  def change
    rename_column :links, :project_id, :project_from_id
    add_column :links, :project_to_id, :string
  end
end
