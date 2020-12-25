# == Schema Information
#
# Table name: issues
#
#  id                :bigint           not null, primary key
#  number_in_project :bigint           not null
#  title             :string           not null
#  description       :text             not null
#  state             :string           not null
#  tags              :string           default([]), is an Array
#  custom_fields     :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  jira_user_id      :bigint           not null
#  project_id        :string
#
# Indexes
#
#  index_issues_on_jira_user_id                      (jira_user_id)
#  index_issues_on_number_in_project                 (number_in_project)
#  index_issues_on_project_id_and_number_in_project  (project_id,number_in_project) UNIQUE
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

  scope :for_project, ->(project_id) { where(project_id: project_id) }
end
