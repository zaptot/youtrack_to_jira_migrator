class CreateDelayedImports < ActiveRecord::Migration[6.0]
  def change
    create_table :delayed_imports do |t|
      t.string :name
      t.string :file_path
      t.string :state
      t.string :project_id, index: true

      t.timestamps
    end
  end
end
