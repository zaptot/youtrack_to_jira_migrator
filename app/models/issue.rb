# == Schema Information
#
# Table name: issues
#
#  id            :bigint           not null, primary key
#  title         :string
#  description   :text
#  state         :string
#  status        :string
#  type          :string
#  estimation    :string
#  custom_fields :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  jira_user_id  :bigint
#  project_id    :string
#
# Indexes
#
#  index_issues_on_jira_user_id       (jira_user_id)
#  index_issues_on_project_id_and_id  (project_id,id) UNIQUE
#
class Issue < ApplicationRecord
  self.inheritance_column = :_type_disabled

  include Syncable

  with_options required: true, dependent: :destroy do
    belongs_to :jira_user
    belongs_to :project
  end

  with_options dependent: :destroy do
    has_many :links, foreign_key: :issue_from_id
    has_many :attachments, as: :reference
    has_many :comments
  end
end
