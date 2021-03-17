# frozen_string_literal: true

module Youtrack::Scrappers
  class Base
    attr_reader :client, :issue

    API_PATH = 'api_path'
    ATTRIBUTES_PARAMS = {}.freeze
    PAGINATE_SIZE = 5_000

    class << self
      def scrape(client, project_id)
        result = []
        1.step do |page|
          response = JSON(client.get([self::API_PATH], params: request_params(project_id, page)).body_str)
          result << response

          break if response.size < paginate_size
        end

        result.flatten
      rescue => e
        # youtrack cannot return too old issue activities cause of timeout
        Rails.logger.info("NOT ALL HISTORIES DOWNLOADED!!! ERROR MESSAGE: #{e.message}")
        result.flatten
      end

      protected

      def paginate_params(page)
        {
          '$skip' => (page - 1) * paginate_size,
          '$top' => paginate_size
        }
      end

      def project_params(project_id)
        { query: "project:#{project_id}" }
      end

      def request_params(project_id, page)
        self::ATTRIBUTES_PARAMS.merge(project_params(project_id)).merge(paginate_params(page))
      end

      def paginate_size
        PAGINATE_SIZE
      end
    end
  end
end
