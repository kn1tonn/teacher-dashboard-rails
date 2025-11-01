class CreateMemos < ActiveRecord::Migration[8.1]
  def change
    create_table :memos do |t|
      t.references :user, null: false, foreign_key: true
      t.references :submission, null: true, foreign_key: true
      t.text :body, null: false
      t.integer :visibility, null: false, default: 0

      t.timestamps
    end

    add_index :memos, :visibility
  end
end
