# encoding: utf-8
class Admin::BestellrundenController < Admin::BaseController
  inherit_resources


  def index
    @bestellrunden = Bestellrunde.order('starts ASC')


    @bestellrunden = @bestellrunden.page(params[:page]).per(@per_page)
  end
end
