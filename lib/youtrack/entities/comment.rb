# frozen_string_literal: true

module Youtrack::Entities
  class Comment
    attr_reader :comment

    def initialize(comment_attrs)
      @comment = comment_attrs.with_indifferent_access
    end

    def author
      User.new(comment[:author])
    end

    def created_at
      Time.at(comment[:created].to_i / 1000)
    end

    def body
      comment[:text]
    end

    def issue_number_in_project
      comment.dig(:issue, :numberInProject)
    end
  end
end
