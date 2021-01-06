# frozen_string_literal: true

module Youtrack::Synchronizer::ImageDownloader
  module_function

  def download_attachments(project_id)
    Attachment.preload(:issue).for_project(project_id).not_downloaded.find_each do |attachment|
      Down.download(image_url(project_id, attachment.url), destination: save_path(attachment))

      attachment.download!
    rescue => e
      attachment.fail!
    end
  end

  def save_path(attachment)
    Rails.root.join(Attachment::FOLDER_PATH).join(attachment.file_name)
  end

  def project(project_id)
    @project ||= Project.find(project_id)
  end

  def image_url(project_id, path)
    File.join(project(project_id).youtrack_url, path)
  end
end
