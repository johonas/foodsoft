# encoding: utf-8
class Admin::DepotsController < Admin::BaseController
  inherit_resources
  
  def index
    @depots = Depot.order('name ASC')

    # if somebody uses the search field:
    unless params[:query].blank?
      @depots = @depots.where('name LIKE ?', "%#{params[:query]}%")
    end

    @depots = @depots.page(params[:page]).per(@per_page)
  end
end
