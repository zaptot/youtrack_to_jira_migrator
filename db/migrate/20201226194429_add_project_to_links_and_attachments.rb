class AddProjectToLinksAndAttachments < ActiveRecord::Migration[6.0]
  def change
    add_reference :attachments, :project, type: :string
    add_reference :links, :project, type: :string
  end
end
