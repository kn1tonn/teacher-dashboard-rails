class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.jsonb :payload, null: false, default: {}
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, :kind
    add_index :notifications, :read_at
    add_index :notifications, %i[user_id kind]
  end
end
