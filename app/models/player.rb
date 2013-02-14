class Player < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :number, :position, :team_name, :team_city, :url
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :number, :presence => true
  validates :position, :presence => true
  #validates :team_name, :presence => true
  #validates :team_city, :presence => true
  validates :url, :presence => true

  searchable do
    text :first_name
    text :last_name
  end
end
