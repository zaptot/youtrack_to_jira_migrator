# frozen_string_literal: true

module Youtrack::Entities
  class Worklog
    attr_reader :attrs, :project_id

    def initialize(attrs, project_id)
      @attrs = attrs.with_indifferent_access
      @project_id = project_id
    end

    def text
      attrs[:text]
    end

    def author
      User.new(attrs[:author])
    end

    def duration
      attrs.dig(:duration, :minutes).to_i
    end

    def issue_number_in_project
      attrs.dig(:issue, :numberInProject)
    end

    def date
      Time.at(attrs[:date].to_i / 1000)
    end

    def created_at
      Time.at(attrs[:created].to_i / 1000)
    end
  end
end
