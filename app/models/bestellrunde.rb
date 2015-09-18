class Bestellrunde < ActiveRecord::Base
  validates :year, uniqueness: { scope: :season,  message: "Es exisitert bereits eine Bestelltunde für die selektierten Daten." }

  def self.seasons
    return ['Frühling', 'Sommer', 'Herbst', 'Winter']
  end
end
