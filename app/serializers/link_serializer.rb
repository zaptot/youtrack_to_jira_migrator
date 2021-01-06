# frozen_string_literal: true

class LinkSerializer < ActiveModel::Serializer
  attributes :sourceId, :destinationId, type: :name

  def sourceId
    object.issue_from.number_in_project
  end

  def destinationId
    object.issue_to.number_in_project
  end
end
