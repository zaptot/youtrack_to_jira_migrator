# frozen_string_literal: true

class SyntaxMigrator
  class << self
    def migrate_text_to_jira_syntax(text, project_id, attachments_names = [])
      text = text.to_s
      migrate_code_blocks(text)
      migrate_one_code_lines(text)
      migrate_user_mentions(text, project_id)
      migrate_images(text)
      migrate_files(text)
      migrate_urls(text, project_id)
      add_attachments(text, attachments_names)

      text
    end

    private

    def migrate_code_blocks(text)
      text.gsub!('```', '{code}')
    end

    def migrate_one_code_lines(text)
      text.gsub!('`', '{noformat}')
    end

    def migrate_user_mentions(text, project_id)
      available_users = JiraUser.full_names_by_project(project_id)
      available_users.each do |mention|
        text.gsub!("@#{mention}", "[~#{mention}]")
      end
    end

    def migrate_images(text)
      images_to_migrate = text.scan(%r{(!\[\]\(.*\))}).to_a.flatten.compact.uniq

      images_to_migrate.each do |image|
        jira_syntax_image = image.gsub('[](', '').gsub(')', '|width=90%!')
        text.gsub!(image, jira_syntax_image)
      end
    end

    def migrate_files(text)
      files_to_migrate = text.scan(%r{(\[file:.*\])}).to_a.flatten.compact.uniq

      files_to_migrate.each do |file|
        jira_syntax_file = file.gsub('file:', '^')

        text.gsub!(file, jira_syntax_file)
      end
    end

    def migrate_urls(text, project_id)
      url_base = Project.youtrack_url_by_project(project_id)
      urls_to_replace = text.scan(%r{(#{url_base}\S*)}).to_a.flatten.compact.uniq
      issue_id_from_url = ->(url) { url[%r{\/(\w*-\d*)}, 1] }

      urls_to_replace.each do |url|
        issue_id = issue_id_from_url.call(url)
        next if issue_id.blank?

        text.gsub!(url, issue_id)
      end
    end

    def add_attachments(text, attachments)
      attachments.each do |attach|
        text << "\n[^#{attach}]"
      end
    end
  end
end
