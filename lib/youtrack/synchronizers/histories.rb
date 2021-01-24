# frozen_string_literal: true

module Youtrack::Synchronizers
  class Histories < Base
    def sync
      load_users(data_to_load[:users])
      load_changes(data_to_load[:changes])
      project.sync_histories!
    rescue => e
      project.fail!
      raise e
    end

    private

    def data_to_load
      @data_to_load ||= Youtrack::Scrappers::Histories.scrape(client, project_id)
                          .reject { |history_item| history_item.dig('field', 'name').nil? }
                          .each_with_object(Hash.new { |k, v| k[v] = [] }) do |change, memo|
        change = Youtrack::Entities::HistoryItem.new(change)
        memo[:changes] << change
        memo[:users] << change.author
      end
    end

    def load_users(users)
      Loaders::User.load(project_id, users.uniq)
    end

    def load_changes(worklogs)
      Loaders::HistoryItem.load(project_id, worklogs.uniq)
    end
  end
end
