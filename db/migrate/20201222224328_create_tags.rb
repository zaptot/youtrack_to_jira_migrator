class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.string :project_id
      t.string :name
      t.timestamps

      t.index %i[project_id name], unique: true
    end
  end
end
