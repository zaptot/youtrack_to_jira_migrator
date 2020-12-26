# == Schema Information
#
# Table name: attachments
#
#  id         :bigint           not null, primary key
#  comment_id :bigint
#  issue_id   :bigint
#  url        :string
#  name       :string
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_attachments_on_comment_id        (comment_id)
#  index_attachments_on_issue_id          (issue_id)
#  index_attachments_on_issue_id_and_url  (issue_id,url) UNIQUE
#  index_attachments_on_url               (url)
#
class Attachment < ApplicationRecord
  include Syncable

  belongs_to :comment, required: false
  belongs_to :issue
end
