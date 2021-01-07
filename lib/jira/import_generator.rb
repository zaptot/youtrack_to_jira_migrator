# frozen_string_literal: true

module Jira
  class ImportGenerator
    attr_accessor :project_id

    class << self
      def generate(project_id)
        new(project_id).generate
      end
    end

    def initialize(project_id)
      @project_id = project_id
    end

    def generate
      res = {
        users: users,
        links: links,
        projects: projects
      }

      File.open(Rails.root.join('tmp/test_import.json'), 'w') { |file| file.write(res.to_json) }
    end

    private

    def projects
      ActiveModel::ArraySerializer.new(
        Project.where(id: project_id).preload(issues: [:jira_user,
                                                       comments: [:jira_user, :attachments],
                                                       attachments: :project]),
        each_serializer: ProjectSerializer
      ).serializable_array
    end

    def users
      ActiveModel::ArraySerializer.new(
        JiraUser.for_project('TD'),
        each_serializer: JiraUserSerializer
      ).serializable_array
    end

    def links
      ActiveModel::ArraySerializer.new(
        Link.for_project('TD').preload(:issue_to, :issue_from),
        each_serializer: LinkSerializer
      ).serializable_array
    end
  end
end
