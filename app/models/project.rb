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
end
