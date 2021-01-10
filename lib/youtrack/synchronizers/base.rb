# frozen_string_literal: true

module Youtrack::Synchronizers
  class Base
    attr_reader :client, :project
    delegate :id, to: :project

    alias :project_id :id

    class << self
      def sync(client, project_id)
        new(client, project_id).sync
      end
    end

    def initialize(client, project_id)
      @project = Project.find(project_id)
      @client = client
    end

    def sync
      raise NotImplementedError
    end
  end
end
