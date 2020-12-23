module Syncable
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :state do
      state :new, initial: true
      state :pending
      state :synced
      state :failed
      state :processing

      event :start_sync do
        transitions from: [:new, :failed], to: :pending
      end

      event :process do
        transitions from: [:pending], to: :processing
      end

      event :sync do
        transitions from: [:process], to: :synced
      end

      event :fail do
        transitions from: [:process], to: :failed
      end
    end
  end

  def self.states
    %i[new pending processing synced failed]
  end
end
