# frozen_string_literal: true

module Youtrack::Entities
  class Comment
    include Singleton

    attr_reader :comment

    def init(comment_attrs)
      @comment = comment_attrs
      self
    end

    def author
      comment['author']
    end

    def created_at
      Time.at(comment['created'].to_i / 1000)
    end

    def body
      comment['text']
    end

    def issue_number_in_project
      comment.dig('issue', 'numberInProject')
    end
  end
end
