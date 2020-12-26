class CreateAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table :attachments do |t|
      t.references :comment
      t.references :issue
      t.string :url, index: true
      t.string :name
      t.string :state

      t.timestamps

      t.index %i[issue_id name], unique: true
    end
  end
end
