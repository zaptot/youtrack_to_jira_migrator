# frozen_string_literal: true

module Youtrack
  class IssueScrapper
    attr_reader :client, :issue

    ISSUES_API_PATH = 'issues'.freeze
    ISSUE_FIELDS_PARAMS = {
      fields: %w[
        project(shortName)
        numberInProject
        summary
        description
        reporter(email)
        tags(name)
        attachments(name,url)
        links(linkType(name),issues(numberInProject,project(shortName)))
        customFields(name,fieldType,value(name,minutes,email))
        comments(text,author(email),deleted,created,attachments(name,url),issue(numberInProject))
      ].join(',')
    }.freeze
    PAGINATE_SIZE = 1

    class << self
      def get_all_issues_by_project(client, project_id)
        1.step.with_object([]) do |page, issues|
          response = JSON(client.get([ISSUES_API_PATH], params: request_params(project_id, page)).body_str)
          issues << response

          break issues.flatten # if response.size < PAGINATE_SIZE
        end
      end

      def find(client, issue_id)
        JSON(client.get([ISSUES_API_PATH, issue_id], params: ISSUE_FIELDS_PARAMS).body_str)
      end

      private

      def paginate_params(page)
        {
          '$skip' => (page - 1) * PAGINATE_SIZE,
          '$top' => PAGINATE_SIZE
        }
      end

      def project_params(project_id)
        { query: "project:#{project_id}" }
      end

      def request_params(project_id, page)
        ISSUE_FIELDS_PARAMS.merge(project_params(project_id)).merge(paginate_params(page))
      end
    end
  end
end
