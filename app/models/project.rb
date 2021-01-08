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
#
# Indexes
#
#  index_projects_on_id  (id)
#
class Project < ApplicationRecord
  include AASM

  SUCCESS_STATES = %w[synced].freeze

  with_options dependent: :destroy do
    has_many :issues
    has_many :jira_users
    has_many :comments
  end

  enum state: %w[created processing synced failed].map { |status| [status, status] }.to_h

  aasm column: :state, enum: true do
    state :created, initial: true
    state :synced
    state :failed
    state :processing

    event :start_sync do
      transitions from: %i[created synced failed], to: :processing
    end

    event :sync do
      transitions from: %i[processing], to: :synced
    end

    event :fail do
      transitions from: %i[processing created], to: :failed
    end
  end

  def self.youtrack_url_by_project(project_id)
    @youtrack_url_by_project ||= {}
    @youtrack_url_by_project[project_id] ||= Project.find(project_id).youtrack_url
    @youtrack_url_by_project[project_id]
  end
end
