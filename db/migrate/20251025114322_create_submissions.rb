class CreateSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.text :content
      t.string :content_url
      t.datetime :submitted_at
      t.integer :ai_score
      t.text :ai_summary

      t.timestamps
    end

    add_index :submissions, :status
    add_index :submissions, :submitted_at
  end
end
