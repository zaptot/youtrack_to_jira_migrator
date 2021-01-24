# frozen_string_literal: true

module Youtrack::Scrappers
  class Worklogs < Base
    API_PATH = 'workItems'

    # date - The date and time that is assigned to the work item.
    # created - The date when the work item was created.
    ATTRIBUTES_PARAMS = {
      fields: %w[
        text
        date
        created
        author(email,login)
        duration(minutes)
        issue(numberInProject)
      ].join(',')
    }.freeze
  end
end
