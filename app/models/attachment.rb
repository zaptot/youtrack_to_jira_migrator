# == Schema Information
#
# Table name: attachments
#
#  id         :bigint           not null, primary key
#  comment_id :bigint
#  issue_id   :bigint
#  url        :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :string
#
# Indexes
#
#  index_attachments_on_comment_id         (comment_id)
#  index_attachments_on_issue_id           (issue_id)
#  index_attachments_on_issue_id_and_name  (issue_id,name) UNIQUE
#  index_attachments_on_project_id         (project_id)
#  index_attachments_on_url                (url)
#
class Attachment < ApplicationRecord
  FOLDER_PATH = 'app/assets/attachments'

  belongs_to :comment, required: false
  belongs_to :issue
  belongs_to :project

  scope :not_downloaded, -> { where(state: %i[new failed]) }
  scope :for_project, ->(project) { where(project_id: project) }

  def file_name
    [project_id, issue.number_in_project, name].join('_')
  end
end
