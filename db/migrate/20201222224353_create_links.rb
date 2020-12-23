class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.string :type
      t.bigint :issue_from_id, index: true
      t.bigint :issue_to_id, index: true
      t.string :state

      t.timestamps
    end
  end
end
