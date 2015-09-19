class Bestellrunde < ActiveRecord::Base
  validates :year, uniqueness: { scope: :season,  message: "Es exisitert bereits eine Bestelltunde für die selektierten Daten." }

  # todo delete validation

  def season_label
    return Bestellrunde.bestellrunden[self.season.to_sym][:label]
  end

  def label
    "#{season_label}/#{year}"
  end

  def starts
    day = Bestellrunde.bestellrunden[self.season.to_sym][:from][:day]
    month = Bestellrunde.bestellrunden[self.season.to_sym][:from][:month]

    return Date.new(self.year, month, day)
  end

  def ends
    day = Bestellrunde.bestellrunden[self.season.to_sym][:to][:day]
    month = Bestellrunde.bestellrunden[self.season.to_sym][:to][:month]

    return Date.new(self.year, month, day)
  end

  def self.selectable
    Bestellrunde.all.select do |bestelrunde|
      bestelrunde.starts < Date.today
    end.map
  end

  def self.bestellrunden
    return {
        :f => {:label => 'Frühling', :from => {:day => 1, :month => 1}, :to => {:day => 20, :month => 1}},
        :s => {:label => 'Sommer',   :from => {:day => 1, :month => 3}, :to => {:day => 20, :month => 3}},
        :h => {:label => 'Herbst',   :from => {:day => 1, :month => 9}, :to => {:day => 20, :month => 9}},
        :w => {:label => 'Winter',   :from => {:day => 1, :month => 12}, :to => {:day => 20, :month => 12}}
    }
  end

  def self.seasons
    return Bestellrunde.bestellrunden.collect{ |k, v| [v[:label], k]}
  end
end