class BestellrundenController < InheritedResources::Base

  before_filter :authenticate_verteilen

  def index
    @bestellrunden = Bestellrunde.all
  end

  def export
    bestellrunde = Bestellrunde.includes(
      :orders => { :group_orders => [ { :ordergroup => :depot }, { :order_articles => { :article => :supplier }}]}
    ).find(params[:id])

    filename = "bestellrunde_#{bestellrunde.starts}.xlsx"

    Reports::Bestellrunde.new(bestellrunde, filename).generate.send(self)
  end

  private

    def bestellrunde_params
      params.require(:bestellrunde).permit
    end
end

