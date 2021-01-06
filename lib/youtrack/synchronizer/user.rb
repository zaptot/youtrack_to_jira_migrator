# frozen_string_literal: true

module Youtrack::Synchronizer::User
  module_function

  def sync(project_id, users)
    data_to_insert = users.map do |user|
      {
        email: user.email,
        full_name: user.full_name,
        project_id: project_id,
        state: :new,
        created_at: Time.now,
        updated_at: Time.now
      }
    end

    return if data_to_insert.blank?

    JiraUser.insert_all(data_to_insert, unique_by: [:project_id, :email])
  end
end
