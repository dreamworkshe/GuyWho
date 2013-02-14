class AddTeamToPlayers < ActiveRecord::Migration
  def change
    rename_column :players, :firstname, :first_name
    rename_column :players, :lastname, :last_name
    add_column :players, :team_city, :string
    add_column :players, :team_name, :string
  end
end
