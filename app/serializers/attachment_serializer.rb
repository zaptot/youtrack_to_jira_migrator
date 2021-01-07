# frozen_string_literal: true

class AttachmentSerializer < ActiveModel::Serializer
  attributes :name, :uri

  def uri
    File.join(object.project.youtrack_url, object.url)
  end
end
