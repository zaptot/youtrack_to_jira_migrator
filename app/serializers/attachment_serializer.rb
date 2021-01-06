# frozen_string_literal: true

class AttachmentSerializer < ActiveModel::Serializer
  attributes :name, :attacher, :uri

  def attacher
    'admin'
  end

  def uri
    File.join(object.project.youtrack_url, object.url)
  end
end
