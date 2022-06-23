# frozen_string_literal: true

module Youtrack::Scrappers
  class Issues < Base
    API_PATH = 'issues'
    ATTRIBUTES_PARAMS = {
      fields: %w[
        project(shortName)
        numberInProject
        summary
        resolved
        description
        reporter(email,login)
        tags(name)
        created
        voters(original(email,login))
        watchers(issueWatchers(user(email,login)))
        attachments(name,url,draft,removed,issue(numberInProject),comment(author(email,login),text,created))
        links(linkType(name),issues(numberInProject,project(shortName)),direction)
        customFields(name,fieldType,value(name,minutes,login,email,text))
        comments(text,author(email,login),deleted,created,issue(numberInProject))
      ].join(',')
    }.freeze
  end
end
