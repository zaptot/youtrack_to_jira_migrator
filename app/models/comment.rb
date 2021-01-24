# == Schema Information
#
# Table name: comments
#
#  id           :bigint           not null, primary key
#  body         :text
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
#  uniq_comments_index             (project_id,issue_id,jira_user_id,created_at) UNIQUE
#
class Comment < ApplicationRecord
  belongs_to :jira_user
  belongs_to :issue
  has_many :attachments, dependent: :destroy

  scope :for_project, ->(project_id) { where(project_id: project_id) }
end
