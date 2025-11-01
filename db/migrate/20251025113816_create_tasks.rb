class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :task_type, null: false, default: 0
      t.date :due_on
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :tasks, :task_type
    add_index :tasks, :active
    add_index :tasks, :due_on
  end
end
