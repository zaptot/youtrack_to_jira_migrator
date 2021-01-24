# frozen_string_literal: true

module Youtrack::Synchronizers
  class Worklogs < Base
    def sync
      load_users(data_to_load[:users])
      load_worklogs(data_to_load[:worklogs])
      project.sync_worklogs!
    rescue => e
      project.fail!
      raise e
    end

    private

    def data_to_load
      @data_to_load ||= Youtrack::Scrappers::Worklogs.scrape(client, project_id)
                          .each_with_object(Hash.new { |k, v| k[v] = [] }) do |worklog, memo|
        worklog = Youtrack::Entities::Worklog.new(worklog, project_id)
        memo[:worklogs] << worklog
        memo[:users] << worklog.author
      end
    end

    def load_users(users)
      Loaders::User.load(project_id, users.uniq)
    end

    def load_worklogs(worklogs)
      Loaders::Worklog.load(project_id, worklogs.uniq)
    end
  end
end
