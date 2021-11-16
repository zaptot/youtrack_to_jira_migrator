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
#  state          :string
#  jira_url       :string
#  status_field   :string           default("State")
#
# Indexes
#
#  index_projects_on_id  (id)
#
class Project < ApplicationRecord
  include AASM

  SUCCESS_STATES = %w[worklogs_synced issues_synced histories_synced].freeze
  PROCESSING_STATES = %w[processing_worklogs processing_issues processing_histories processing_reset].freeze
  AVAILABLE_STATES = %w[created failed issues_synced worklogs_synced processing_reset project_reset
                        processing_worklogs processing_issues histories_synced processing_histories].freeze

  with_options dependent: :destroy do
    has_many :issues
    has_many :jira_users
    has_many :comments
    has_many :delayed_imports
  end

  enum state: AVAILABLE_STATES.map { |status| [status, status] }.to_h

  aasm column: :state, enum: true do
    state :created, initial: true
    state :failed
    state :issues_synced
    state :worklogs_synced
    state :processing_issues
    state :processing_worklogs
    state :histories_synced
    state :processing_histories
    state :processing_reset
    state :project_reset

    event :sync_issues do
      transitions from: %i[processing_issues], to: :issues_synced
    end

    event :sync_worklogs do
      transitions from: %i[processing_worklogs], to: :worklogs_synced
    end

    event :sync_histories do
      transitions from: %i[processing_histories], to: :histories_synced
    end

    event :start_sync_worklogs do
      transitions from: SUCCESS_STATES, to: :processing_worklogs
    end

    event :start_sync_histories do
      transitions from: SUCCESS_STATES, to: :processing_histories
    end

    event :start_sync_issues do
      transitions from: SUCCESS_STATES + %i[created failed project_reset], to: :processing_issues
    end

    event :fail do
      transitions from: PROCESSING_STATES + %i[created], to: :failed
    end

    event :start_reset_project do
      transitions from: SUCCESS_STATES + %i[created failed], to: :processing_reset
    end

    event :reset_project do
      transitions from: %i[processing_reset], to: :project_reset
    end
  end

  def processing?
    PROCESSING_STATES.include?(state)
  end

  def can_sync_additional_info?
    SUCCESS_STATES.include?(state)
  end

  def can_reset_project?
    (SUCCESS_STATES + %i[created failed]).include?(state)
  end
end
