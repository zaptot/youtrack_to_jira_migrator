# == Schema Information
#
# Table name: worklogs
#
#  id           :bigint           not null, primary key
#  text         :string
#  date         :datetime         not null
#  duration     :integer
#  project_id   :string           not null
#  jira_user_id :bigint
#  issue_id     :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_worklogs_on_issue_id      (issue_id)
#  index_worklogs_on_jira_user_id  (jira_user_id)
#  index_worklogs_on_project_id    (project_id)
#
class Worklog < ApplicationRecord
  belongs_to :issue, required: true
  belongs_to :jira_user, required: true
  belongs_to :project, required: true

  scope :for_project, ->(project_id) { where(project_id: project_id) }

  def duration_period
    "PT#{duration}M"
  end
end
