class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :submission, null: false, foreign_key: true
      t.text :teacher_comment
      t.datetime :published_at

      t.timestamps
    end

    add_index :feedbacks, :published_at
  end
end
