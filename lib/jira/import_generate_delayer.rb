# frozen_string_literal: true

module Jira
  class ImportGenerateDelayer
    FOLDER_NAME = 'imports'

    attr_reader :project

    def initialize(project)
      @project = project
    end

    def enqueue
      delay = DelayedImport.create!(project: project, name: file_name, file_path: file_path)
      DelayImportJob.perform_async(delay.id)
    end

    private

    def file_name
      @file_name ||= "#{project.id}_import_#{Time.now.to_i}.json"
    end

    def file_path
      FileUtils.mkdir_p(Rails.root.join(FOLDER_NAME))
      File.join(FOLDER_NAME, file_name)
    end
  end
end
