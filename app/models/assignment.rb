class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :task

  scope :accepted, -> { where(accepted: true) }

  validates :people_count, numericality: { greater_than_or_equal_to: 1 }
end
