class UpdateProviderUidIndexOnUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, %i[provider uid]
    add_index :users, %i[provider uid], unique: true, where: "provider IS NOT NULL AND uid IS NOT NULL"
  end
end
