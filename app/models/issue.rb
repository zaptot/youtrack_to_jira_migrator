# == Schema Information
#
# Table name: issues
#
#  id                :bigint           not null, primary key
#  number_in_project :bigint           not null
#  title             :string           not null
#  description       :text
#  tags              :string           default([]), is an Array
#  custom_fields     :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  jira_user_id      :bigint           not null
#  project_id        :string
#  resolved          :datetime
#  voters            :string           is an Array
#  watchers          :string           is an Array
#
# Indexes
#
#  index_issues_on_jira_user_id                      (jira_user_id)
#  index_issues_on_number_in_project                 (number_in_project)
#  index_issues_on_project_id_and_number_in_project  (project_id,number_in_project) UNIQUE
#
class Issue < ApplicationRecord
  self.inheritance_column = :_type_disabled

  SYSTEM_CUSTOM_FIELDS = (%w[Assignee Type Estimation State Priority] + ['Spent time', 'Fix versions']).freeze

  with_options required: true do
    belongs_to :jira_user
    belongs_to :project, inverse_of: :issues
  end

  with_options dependent: :destroy do
    has_many :links, foreign_key: :issue_from_id
    has_many :attachments
    has_many :comments
    has_many :worklogs
    has_many :issue_histories
  end

  scope :for_project, ->(project_id) { where(project_id: project_id) }

  class << self
    def system_field_values(system_field_name)
      pluck(:custom_fields).flatten.uniq.select { |field| field['field_name'] == system_field_name }.map { |field| field['value'] }
    end
  end

  def assignee
    custom_field_by_name('Assignee')&.dig('value')
  end

  def status
    SyntaxMigrator.normalized_history_values('status', custom_field_by_name(status_field)&.dig('value'))
  end

  def fix_versions
    [custom_field_by_name('Fix versions')&.dig('value')].compact
  end

  def type
    custom_field_by_name('Type')&.dig('value')
  end

  def priority
    custom_field_by_name('Priority')&.dig('value')
  end

  def time_spent
    time = custom_field_by_name('Spent time')&.dig('value')
    "PT#{time.to_i}M"
  end

  def estimate
    time = custom_field_by_name('Estimation')&.dig('value')
    "PT#{time.to_i}M"
  end

  def custom_fields_without_system
    custom_fields.reject { |field| field['field_name'].in?(SYSTEM_CUSTOM_FIELDS + [status_field]) }
  end

  private

  def custom_field_by_name(name)
    custom_fields.find { |field| field['field_name'] == name }
  end

  def status_field
    @status_field ||= Project.find(project_id).status_field
  end
end
