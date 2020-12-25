# == Schema Information
#
# Table name: links
#
#  id            :bigint           not null, primary key
#  type          :string
#  issue_from_id :bigint
#  issue_to_id   :bigint
#  state         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_links_on_issue_from_id                           (issue_from_id)
#  index_links_on_issue_to_id                             (issue_to_id)
#  index_links_on_type_and_issue_from_id_and_issue_to_id  (type,issue_from_id,issue_to_id) UNIQUE
#
class Link < ApplicationRecord
  self.inheritance_column = :_type_disabled

  with_options required: true do
    belongs_to :issue_from, class_name: 'Issue', foreign_key: :issue_from_id
    belongs_to :issue_to, class_name: 'Issue', foreign_key: :issue_to_id
  end
end
