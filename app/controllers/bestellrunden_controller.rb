class BestellrundenController < InheritedResources::Base
  before_filter :authenticate_verteilen

  def index
    @bestellrunden = Bestellrunde.all
  end

  def distribution_export
    filename = "bestellrunde_#{bestellrunde.starts}.xlsx"

    Reports::Bestellrunde.new(bestellrunde, filename).generate.send(self)
  end

  def depot_export
    depot = Depot.find(params[:depot_id])

    filename = "bestellrunde_#{bestellrunde.starts}_depot_#{depot.name.downcase.gsub(' ', '_')}.xlsx"

    Reports::BestellrundeDepot.new(bestellrunde, depot, filename).generate.send(self)
  end

  private

  def bestellrunde
    Bestellrunde.includes(
      :orders => { :group_orders => [ { :ordergroup => :depot }, { :order_articles => { :article => :supplier }}]}
    ).find(params[:id])
  end

  def bestellrunde_params
    params.require(:bestellrunde).permit
  end
end

