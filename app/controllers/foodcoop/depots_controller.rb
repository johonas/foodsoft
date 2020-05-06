class Foodcoop::DepotsController < ApplicationController
  before_filter :authenticate_membership_or_admin,
                :except => [:index]

  def index
    @depots = Depot.order("name")

    unless params[:name].blank? # Search by name
      @depots = @depots.where('name LIKE ?', "%#{params[:name]}%")
    end
  end
end
