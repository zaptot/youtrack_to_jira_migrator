# == Schema Information
#
# Table name: comments
#
#  id           :bigint           not null, primary key
#  body         :text
#  state        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  jira_user_id :bigint           not null
#  project_id   :string
#  issue_id     :bigint           not null
#
# Indexes
#
#  index_comments_on_issue_id      (issue_id)
#  index_comments_on_jira_user_id  (jira_user_id)
#  index_comments_on_project_id    (project_id)
#
class Comment < ApplicationRecord
  include Syncable

  belongs_to :jira_user
  belongs_to :issue
  has_many :attachments, dependent: :destroy
end
