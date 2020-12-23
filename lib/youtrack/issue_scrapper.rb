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
        reporter(fullName)
        tags(name)
        attachments(name,url)
        links(linkType(name),issues(numberInProject,project(shortName)))
        customFields(name,fieldType,value(name,minutes))
        comments(text,author(email),deleted,textPreview,created,attachments(name,url))
      ].join(',')
    }.freeze

    class << self
      def get_all_issues_by_project(client, project_id)
        project_filter = { query: "project:#{project_id}" }.merge(ISSUE_FIELDS_PARAMS)
        JSON(client.get([ISSUES_API_PATH], params: project_filter).body_str)
      end

      def find(client, issue_id)
        JSON(client.get([ISSUES_API_PATH, issue_id], params: ISSUE_FIELDS_PARAMS).body_str)
      end
    end
  end
end
