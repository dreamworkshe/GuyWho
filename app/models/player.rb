class Player < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :number, :position, :team_name, :team_city, :url
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :number, :presence => true
  validates :position, :presence => true
  validates :team_name, :presence => true
  validates :team_city, :presence => true
  validates :url, :presence => true

  # TODO: downcase
  searchable do
    text :first_name do
      self.first_name.downcase
    end
    text :last_name do
      self.last_name.downcase
    end
    text :team_name do
      self.team_name.downcase
    end
    text :team_city do
      self.team_city.downcase
    end
    text :number do
      self.number.to_s
    end
  end
end
