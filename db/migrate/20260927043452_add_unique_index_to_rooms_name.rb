class AddUniqueIndexToRoomsName < ActiveRecord::Migration[8.1]
  def change
    add_index :rooms, :name, unique: true
  end
end
