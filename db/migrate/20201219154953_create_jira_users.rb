# frozen_string_literal: true

class CreateJiraUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :jira_users do |t|
      t.string :email
      t.string :state

      t.timestamps
    end
  end
end
