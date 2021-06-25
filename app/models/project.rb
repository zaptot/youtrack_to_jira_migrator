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
#
# Indexes
#
#  index_projects_on_id  (id)
#
class Project < ApplicationRecord
  include AASM

  SUCCESS_STATES = %w[worklogs_synced issues_synced histories_synced].freeze
  AVAILABLE_STATES = %w[created failed issues_synced worklogs_synced
                        processing_worklogs processing_issues histories_synced processing_histories].freeze

  with_options dependent: :destroy do
    has_many :issues
    has_many :jira_users
    has_many :comments
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
      transitions from: %i[created worklogs_synced issues_synced histories_synced failed], to: :processing_issues
    end

    event :fail do
      transitions from: %i[processing_worklogs processing_issues processing_histories created], to: :failed
    end
  end

  def processing?
    state.in?(%w[processing_worklogs processing_issues processing_histories])
  end

  def can_sync_additional_info?
    SUCCESS_STATES.include?(state)
  end
end
