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
      state :updated
      state :downloaded

      event :notify_updated do
        transitions from: %i[synced], to: :updated
      end

      event :download do
        transitions from: %i[new], to: :downloaded
      end

      event :start_sync do
        transitions from: %i[new failed updated downloaded], to: :pending
      end

      event :process do
        transitions from: %i[pending], to: :processing
      end

      event :sync do
        transitions from: %i[processing], to: :synced
      end

      event :fail do
        transitions from: %i[processing new], to: :failed
      end
    end
  end

  def self.states
    %i[new pending processing synced failed updated downloaded]
  end
end
