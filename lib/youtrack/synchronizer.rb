# frozen_string_literal: true

module Youtrack
  class Synchronizer
    attr_accessor :project, :client

    delegate :youtrack_url, :youtrack_token, :id, to: :project

    def initialize(project_id)
      @project = Project.find(project_id)
      @client = Client.new(youtrack_url, youtrack_token)
    end

    def sync
      sync_users(data_to_sync[:users])
      sync_issues(data_to_sync[:issues])
      sync_comments(data_to_sync[:comments])
      sync_links(data_to_sync[:links])
      sync_attachments(data_to_sync[:attachments])
    end

    private

    def data_to_sync
      @data_to_sync ||= IssueScrapper.get_all_issues_by_project(client, id)
                                     .each_with_object(Hash.new { |k, v| k[v] = Set.new }) do |issue, memo|
        issue = Entities::Issue.new(issue)
        memo[:issues] << issue
        memo[:comments] += issue.comments
        memo[:links] += issue.links
        memo[:users] += [issue.author, issue.assignee.user].compact +
                         issue.comments.map { |comment| comment.author }
        memo[:attachments] += issue.attachments
      end
    end

    def sync_users(users)
      Synchronizer::User.sync(id, users)
    end

    def sync_issues(issues)
      Synchronizer::Issue.sync(id, issues)
    end

    def sync_comments(comments)
      Synchronizer::Comment.sync(id, comments)
    end

    def sync_attachments(attachments)
      Synchronizer::Attachment.sync(id, attachments)
    end

    def sync_links(links)
      Synchronizer::Link.sync(id, links)
    end

    # no need in it=))

    def download_attachments
      Synchronizer::ImageDownloader.download_attachments(id)
    end
  end
end
