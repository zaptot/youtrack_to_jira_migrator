# frozen_string_literal: true

module Youtrack::Scrappers
  class Histories < Base
    API_PATH = 'activities'
    ATTRIBUTES_PARAMS = {
      fields: %w[
        author(login,email)
        timestamp
        removed(name)
        added(name)
        target(numberInProject)
        field(name)
      ].join(','),
      categories: %w[
        CustomFieldCategory
        DescriptionCategory
        SummaryCategory
      ].join(',')
    }.freeze

    class << self
      protected

      def project_params(project_id)
        { issueQuery: "project:#{project_id}" }
      end

      def paginate_size
        15_000
      end
    end
  end
end
