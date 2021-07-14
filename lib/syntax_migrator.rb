# frozen_string_literal: true

class SyntaxMigrator
  class << self
    def migrate_text_to_jira_syntax(text, project, attachments_names = [])
      text = text.to_s
      migrate_code_blocks(text)
      migrate_one_code_lines(text)
      migrate_user_mentions(text, project.id)
      migrate_images(text)
      migrate_files(text)
      migrate_youtrack_urls(text, project)
      migrate_named_urls(text)
      add_attachments(text, attachments_names)
      migrate_character_formatting(text)
      migrate_headings(text)
      migrate_tables(text)
      migrate_block_quotes(text)
      migrate_check_lists(text)
      migrate_lists(text)

      text
    end

    def normalized_history_values(field_name, value)
      return value if value.blank?

      case field_name.downcase
      when 'due date'
        Time.at(value.to_i / 1000).strftime('%d/%b/%y')
      when 'status'
        value.titleize
      when 'estimation', 'spent time'
        minutes_to_period(value)
      else
        value
      end
    end

    private

    def minutes_to_period(number_of_minutes)
      return '' if number_of_minutes.to_i < 1

      weeks = ->(minutes) { "#{minutes.minutes / (5 * 8).hours}w" }
      days = ->(minutes) { "#{(minutes.minutes % (5 * 8).hours) / 8.hours}d" }
      hours = ->(minutes) { "#{(minutes.minutes % 8.hours) / 1.hour}h" }
      minutes = ->(minutes) { "#{minutes.minutes % 1.hour}m" }
      [weeks, days, hours, minutes].map { |period| period.call(number_of_minutes.to_i) }
                                   .reject { |period| period =~ /0[wdhm]{1}/ }
                                   .join(' ')
    end

    def migrate_code_blocks(text)
      text.gsub!('```', '{code}')
    end

    def migrate_one_code_lines(text)
      text.gsub!('`', '{noformat}')
      text.gsub!('``', '{noformat}')
    end

    def migrate_user_mentions(text, project_id)
      available_users = JiraUser.full_names_by_project(project_id)
      available_users.each do |mention|
        text.gsub!("@#{mention}", "[~#{mention}]")
      end
    end

    def migrate_images(text)
      images_to_migrate = text.scan(%r{(!\[\]\(.*?\))}).to_a.flatten.compact.uniq

      images_to_migrate.each do |image|
        jira_syntax_image = image.gsub('[](', '').gsub(')', '|width=90%!')
        text.gsub!(image, jira_syntax_image)
      end
    end

    def migrate_files(text)
      files_to_migrate = text.scan(%r{(\[file:.*?\])}).to_a.flatten.compact.uniq

      files_to_migrate.each do |file|
        jira_syntax_file = file.gsub('file:', '^')

        text.gsub!(file, jira_syntax_file)
      end
    end

    def migrate_youtrack_urls(text, project)
      url_base = project.youtrack_url
      jira_url = project.jira_url
      urls_to_replace = text.scan(%r{(#{url_base})(\S*)}).to_a.compact.uniq
      issue_id_from_url = ->(url) { url[%r{\/(\w*-\d*)}, 1] }

      urls_to_replace.each do |url_base, url_path|
        issue_id = issue_id_from_url.call(url_path)
        next if issue_id.blank?

        text.gsub!([url_base, url_path].join, File.join(jira_url, 'browse', issue_id))
      end
    end

    def migrate_named_urls(text)
      urls_with_names = text.scan(%r{\[(\S+?)\]\((\S+?)\)}).to_a.compact.uniq

      urls_with_names.each do |name, url|
        old_url = "[#{name}](#{url})"
        new_url = "[#{name}|#{url}]"
        text.gsub!(old_url, new_url)
      end
    end

    def migrate_character_formatting(text)
      text.gsub!('**', '§§§').gsub!('*','_').gsub!('§§§','*').gsub!('~~', '-')
    end

    def migrate_headings(text)
      if text.match?(/^#/)
        level = text.scan(/^#+/).first.length
        text.gsub!(/^#{Regexp.escape('#'*level)}/, "h#{level}")
      end

      6.downto(1) do |h|
        text.gsub!(/\\n#{Regexp.escape('#'*h)}/, "\nh#{h}")
      end
    end

    def migrate_tables(text)
      text.scan(%r{(^(\|:{0,1}-+:{0,1})+\|$)}).each do |full_row, _|
        text.gsub!("#{full_row}\n", '')
        text.gsub!(full_row, '')
      end
    end

    def migrate_check_lists(text)
      text.gsub!('- [ ]', '(-)')
      text.gsub!('- [x]', '(+)')
    end

    def add_attachments(text, attachments)
      attachments.each do |attach|
        text << "\n[^#{attach}]"
      end
    end

    def migrate_lists(text)
      text.gsub!(/((?:[1-9]+\.|[*-])[\s\S]+?)(?:\n\n|\z)/, '{code}\1{code}')
    end
  end
end
