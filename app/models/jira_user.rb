# == Schema Information
#
# Table name: jira_users
#
#  id         :bigint           not null, primary key
#  email      :string
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :string
#
# Indexes
#
#  index_jira_users_on_project_id_and_email  (project_id,email) UNIQUE
#
class JiraUser < ApplicationRecord
  include Syncable

  with_options dependent: :destroy do
    has_many :comments
    has_many :issues
  end

  belongs_to :project, required: true

  scope :for_project, ->(project) { where(project_id: project) }
end
