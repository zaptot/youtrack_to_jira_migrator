# frozen_string_literal: true

class LinkSerializer < ActiveModel::Serializer
  attributes :sourceId, :destinationId, type: :name

  def sourceId
    "#{object.project_from_id}-#{object.issue_from.number_in_project}"
  end

  def destinationId
    "#{object.project_to_id}-#{object.issue_to.number_in_project}"
  end
end
