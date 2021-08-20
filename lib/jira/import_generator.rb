# frozen_string_literal: true

module Jira
  class ImportGenerator
    attr_accessor :delay, :project_id

    class << self
      def generate(delay_id)
        new(delay_id).generate
      end
    end

    def initialize(delay_id)
      @delay = DelayedImport.find(delay_id)
      @project_id = delay.project_id
    end

    def generate
      finish_import_generator!(users: users, links: links, projects: projects)
    rescue => e
      delay.fail!
      raise e
    end

    private

    def projects
      ActiveModel::ArraySerializer.new(
        Project.where(id: project_id).preload(issues: [:jira_user,
                                                       :project,
                                                       comments: [:jira_user, :attachments, :project],
                                                       attachments: :project,
                                                       worklogs: [:jira_user, :project],
                                                       issue_histories: [:jira_user, :project]]),
        each_serializer: ProjectSerializer
      ).serializable_array
    end

    def users
      ActiveModel::ArraySerializer.new(
        JiraUser.for_project(project_id),
        each_serializer: JiraUserSerializer
      ).serializable_array
    end

    def links
      ActiveModel::ArraySerializer.new(
        Link.for_project(project_id).preload(:issue_to, :issue_from),
        each_serializer: LinkSerializer
      ).serializable_array
    end

    def finish_import_generator!(import_data)
      File.open(delay.file_path, 'w') { |file| file.write(import_data.to_json) }
      delay.finish!
    end
  end
end
