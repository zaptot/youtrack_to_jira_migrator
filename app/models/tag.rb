# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  project_id :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_project_id_and_name  (project_id,name) UNIQUE
#
class Tag < ApplicationRecord
  belongs_to :project, required: true
end
