class Bestellrunde < ActiveRecord::Base
  has_many :orders

  def season_label
    return Bestellrunde.bestellrunden[self.season.to_sym][:label]
  end

  def label
    "#{self.starts}"
  end

  def self.selectable
    Bestellrunde.all.select do |bestelrunde|
      bestelrunde.starts > Date.today
    end.map
  end

end