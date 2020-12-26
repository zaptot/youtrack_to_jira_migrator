# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[6.0]
  def change
    create_table :issues do |t|
      t.bigint :number_in_project, null: false, index: true
      t.string :title, null: false
      t.text :description
      t.string :state, null: false
      t.string :tags, array: true, default: []

      t.jsonb :custom_fields, default: {}

      t.timestamps
    end
  end
end
