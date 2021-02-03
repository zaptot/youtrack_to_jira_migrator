# frozen_string_literal: true

module Youtrack::Synchronizers
  class Issues < Base
    def sync
      load_users(data_to_load[:users])
      load_issues(data_to_load[:issues])
      load_comments(data_to_load[:comments])
      load_links(data_to_load[:links])
      load_attachments(data_to_load[:attachments])
      project.sync_issues!
    rescue => e
      project.fail!
      raise e
    end

    private

    def data_to_load
      @data_to_sync ||= Youtrack::Scrappers::Issues.scrape(client, project_id)
                          .each_with_object(Hash.new { |k, v| k[v] = [] }) do |issue, memo|
        issue = Youtrack::Entities::Issue.new(issue)
        memo[:issues] << issue
        memo[:comments] += issue.comments
        memo[:links] += issue.links
        memo[:users] += [issue.author, issue.assignee.user].compact +
                        issue.comments.map { |comment| comment.author } +
                        issue.voters + issue.watchers
        memo[:attachments] += issue.attachments
      end
    end

    def load_users(users)
      Loaders::User.load(project_id, users)
    end

    def load_issues(issues)
      Loaders::Issue.load(project_id, issues)
    end

    def load_comments(comments)
      Loaders::Comment.load(project_id, comments)
    end

    def load_attachments(attachments)
      Loaders::Attachment.load(project_id, attachments)
    end

    def load_links(links)
      Loaders::Link.load(project_id, links)
    end
  end
end
