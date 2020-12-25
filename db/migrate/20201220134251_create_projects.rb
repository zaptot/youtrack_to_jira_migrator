# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects, id: :string do |t|
      t.string :full_name, null: false
      t.string :youtrack_token, null: false
      t.string :youtrack_url, null: false

      t.timestamps

      t.index :id
    end
  end
end
