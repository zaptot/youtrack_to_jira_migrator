class AddIssueIdToComments < ActiveRecord::Migration[6.0]
  def change
    add_reference :comments, :issue
  end
end
