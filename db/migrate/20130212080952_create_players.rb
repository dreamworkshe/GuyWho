class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :firstname
      t.string :lastname
      t.integer :number
      t.string :position

      t.timestamps
    end
  end
end
