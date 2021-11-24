class AddStatusFieldToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :status_field, :string, default: 'State'
  end
end
