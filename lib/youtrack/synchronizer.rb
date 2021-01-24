# frozen_string_literal: true

module Youtrack
  class Synchronizer
    attr_accessor :project, :client

    delegate :youtrack_url, :youtrack_token, :id, to: :project

    def initialize(project_id)
      @project = Project.find(project_id)
      @client = Client.new(youtrack_url, youtrack_token)
    end

    def sync_issues
      Synchronizers::Issues.sync(client, id)
    end

    def sync_worklogs
      Synchronizers::Worklogs.sync(client, id)
    end

    def sync_histories
      Synchronizers::Histories.sync(client, id)
    end
  end
end
