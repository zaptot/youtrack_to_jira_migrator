# frozen_string_literal: true
# == Schema Information
#
# Table name: delayed_imports
#
#  id         :bigint           not null, primary key
#  name       :string
#  file_path  :string
#  state      :string
#  project_id :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_delayed_imports_on_project_id  (project_id)
#
class DelayedImport < ApplicationRecord
  include AASM

  AVAILABLE_STATES = %w[created finished deleted].freeze

  enum state: AVAILABLE_STATES.map { |status| [status, status] }.to_h

  belongs_to :project, required: true

  scope :not_deleted, -> { where.not(state: :deleted).order(updated_at: :desc) }

  aasm column: :state, enum: true do
    state :created, initial: true
    state :finished
    state :failed
    state :deleted

    event :finish do
      transitions from: %i[created], to: :finished
    end

    event :mark_as_deleted do
      transitions from: %i[created finished], to: :deleted
    end

    event :fail do
      transitions from: %i[created finished], to: :failed
    end
  end
end
