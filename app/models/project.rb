# == Schema Information
#
# Table name: projects
#
#  id             :string           not null, primary key
#  full_name      :string           not null
#  youtrack_token :string           not null
#  youtrack_url   :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  workflow_name  :string
#
# Indexes
#
#  index_projects_on_id  (id)
#
class Project < ApplicationRecord
  with_options dependent: :destroy do
    has_many :issues
    has_many :jira_users
    has_many :comments
  end

  def self.youtrack_url_by_project(project_id)
    @youtrack_url_by_project ||= {}
    @youtrack_url_by_project[project_id] ||= Project.find(project_id).youtrack_url
    @youtrack_url_by_project[project_id]
  end
end
