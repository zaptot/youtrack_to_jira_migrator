# frozen_string_literal: true

module Youtrack::Synchronizers
  class Worklogs < Base
    def sync
      load_users(data_to_load[:users])
      load_worklogs(data_to_load[:worklogs])
      project.sync_worklogs!
    rescue
      project.fail!
    end

    private

    def data_to_load
      @data_to_load ||= Youtrack::Scrappers::Worklogs.scrape(client, project_id)
                          .each_with_object(Hash.new { |k, v| k[v] = Set.new }) do |worklog, memo|
        worklog = Youtrack::Entities::Worklog.new(worklog, project_id)
        memo[:worklogs] << worklog
        memo[:users] << worklog.author
      end
    end

    def load_users(users)
      Loaders::User.load(project_id, users)
    end

    def load_worklogs(worklogs)
      Loaders::Worklog.load(project_id, worklogs)
    end
  end
end