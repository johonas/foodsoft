class Depot < ActiveRecord::Base
  validates_presence_of :name

  def self.collection
    Depot.all.map{ |depot| [depot.name, depot.id]}
  end
end
