# frozen_string_literal: true

class ProjectSerializer < ActiveModel::Serializer
  attributes :type, :workflowSchemeName, :versions, full_name: :name, id: :key

  has_many :issues

  def type
    :software
  end

  def workflowSchemeName
    'asdf'
  end

  def versions
    object.issues.system_field_values('Fix versions')
  end
end
