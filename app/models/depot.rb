class Depot < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'

  attr_reader :user_tokens


  validates_presence_of :name
  validates_presence_of :owner

  def self.collection
    Depot.all.map{ |depot| [depot.name, depot.id]}
  end

  def user_tokens=(ids)
    self.user_ids = ids.split(",")
  end
end
