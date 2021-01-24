# == Schema Information
#
# Table name: issue_histories
#
#  id           :bigint           not null, primary key
#  jira_user_id :bigint           not null
#  issue_id     :bigint           not null
#  project_id   :string           not null
#  field_name   :string           not null
#  field_type   :string           not null
#  from_string  :string
#  to_string    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_issue_histories_on_issue_id      (issue_id)
#  index_issue_histories_on_jira_user_id  (jira_user_id)
#  index_issue_histories_on_project_id    (project_id)
#
class IssueHistory < ApplicationRecord
  belongs_to :issue
  belongs_to :jira_user
  belongs_to :project

  scope :for_project, ->(project_id) { where(project_id: project_id) }
end
