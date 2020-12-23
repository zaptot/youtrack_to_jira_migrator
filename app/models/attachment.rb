# == Schema Information
#
# Table name: attachments
#
#  id             :bigint           not null, primary key
#  reference_type :string
#  reference_id   :bigint
#  url            :string
#  name           :string
#  state          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_attachments_on_reference_type_and_reference_id  (reference_type,reference_id)
#  index_attachments_on_url                              (url)
#
class Attachment < ApplicationRecord
  include Syncable

  belongs_to :reference, polymorphic: true, inverse_of: :attachments, required: true
end
