# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[6.0]
  def change
    create_table :issues do |t|
      t.string :title
      t.text :description
      t.string :state
      t.string :status
      t.string :type
      t.string :estimation
      t.jsonb :custom_fields, default: {}

      t.timestamps
    end
  end
end
