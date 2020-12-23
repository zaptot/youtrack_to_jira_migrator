class CreateAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table :attachments do |t|
      t.string :reference_type
      t.bigint :reference_id
      t.string :url, index: true
      t.string :name
      t.string :state

      t.timestamps
      t.index %i[reference_type reference_id]
    end
  end
end
