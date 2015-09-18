class Depot < ActiveRecord::Base
  has_many :users

  attr_reader :user_tokens


  validates_presence_of :name

  def self.collection
    Depot.all.map{ |depot| [depot.name, depot.id]}
  end

  def user_tokens=(ids)
    self.user_ids = ids.split(",")
  end
end
