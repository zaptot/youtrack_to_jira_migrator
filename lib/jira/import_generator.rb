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
      }.to_json

      File.open(file_path, 'w') { |file| file.write(res) }
      file_path
    end

    private

    def projects
      ActiveModel::ArraySerializer.new(
        Project.where(id: project_id).preload(issues: [:jira_user,
                                                       comments: [:jira_user, :attachments],
                                                       attachments: :project,
                                                       worklogs: :jira_user]),
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

    def file_path
      file_name = "#{project_id}_import_#{Time.now}.json"
      Rails.root.join("tmp/#{file_name}")
    end
  end
end
