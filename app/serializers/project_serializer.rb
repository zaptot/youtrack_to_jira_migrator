# frozen_string_literal: true

class ProjectSerializer < ActiveModel::Serializer
  attributes :type, :versions, full_name: :name, id: :key, workflow_name: :workflowSchemeName

  has_many :issues

  def type
    :software
  end

  def versions
    object.issues.system_field_values('Fix versions')
  end
end
