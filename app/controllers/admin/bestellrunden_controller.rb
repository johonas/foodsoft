# encoding: utf-8
class Admin::BestellrundenController < Admin::BaseController
  inherit_resources


  def index
    @bestellrunden = Bestellrunde.order('year ASC')

    # if somebody uses the search field:
    unless params[:query].blank?
      @bestellrunden = @bestellrunden.where('year LIKE ?', "%#{params[:query]}%")
    end

    @bestellrunden = @bestellrunden.page(params[:page]).per(@per_page)
  end
end
