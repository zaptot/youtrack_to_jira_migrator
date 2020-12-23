# frozen_string_literal: true

module Youtrack::Entities
  class Comment
    attr_reader :comment

    def initialize(comment_attrs)
      @comment = comment_attrs.with_indifferent_access
    end

    def author_email
      comment.dig(:author, :email)
    end

    def created_at
      comment[:created]
    end

    def body
      comment[:text]
    end

    def attachments
      @attachments ||= comment[:attachments]&.map { |attach| Attachment.new(attach) }
    end
  end
end
