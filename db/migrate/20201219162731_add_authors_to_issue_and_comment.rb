# frozen_string_literal: true

class AddAuthorsToIssueAndComment < ActiveRecord::Migration[6.0]
  def change
    add_reference :comments, :jira_user, null: false
    add_reference :issues, :jira_user, null: false
  end
end
