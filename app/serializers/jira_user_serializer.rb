# frozen_string_literal: true

class JiraUserSerializer < ActiveModel::Serializer
  attributes :name, :fullname

  def name
    object.full_name
  end

  def fullname
    object.email
  end
end
