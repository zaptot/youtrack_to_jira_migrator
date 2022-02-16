# frozen_string_literal: true

class ProjectSerializer < ActiveModel::Serializer
  VERSION_FIELDS = ['Fix versions', 'Verified in Version', 'Found in'].freeze

  attributes :type, :versions, full_name: :name, id: :key, workflow_name: :workflowSchemeName

  has_many :issues

  def type
    :software
  end

  def versions
    VERSION_FIELDS.inject([]) { |memo, field| memo += object.issues.system_field_values(field) }.sort.uniq
  end
end
