# frozen_string_literal: true

module Youtrack::Synchronizers::Loaders::User
  module_function

  def load(project_id, users)
    data_to_insert = users.map do |user|
      next if user.email.blank? || user.full_name.blank?

      {
        email: user.email,
        full_name: user.full_name,
        project_id: project_id,
        created_at: Time.now,
        updated_at: Time.now
      }
    end.compact

    return if data_to_insert.blank?

    JiraUser.insert_all(data_to_insert, unique_by: [:project_id, :email])
  end
end
