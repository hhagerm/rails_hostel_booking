class AddGuestsToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :guests, :integer, null: false, default: 1
  end
end
