# encoding: utf-8
class Admin::BestellrundenController < Admin::BaseController
  inherit_resources

  def index
    @q = Bestellrunde.ransack(params[:q])

    @q.sorts = ['starts DESC'] if @q.sorts.empty?

    @bestellrunden = @q.result.page(params[:page]).per(@per_page)
    @bestellrunden = @bestellrunden.page(params[:page]).per(@per_page)
  end
end
