class BestellrundenController < InheritedResources::Base

  before_filter :authenticate_verteilen

  def index
    @bestellrunden = Bestellrunde.all
  end

  def export
    bestellrunde = Bestellrunde.find(params[:id])
    xls = BestellrundeXls.new(bestellrunde)

    send_data(xls.data.string.force_encoding('binary'), :filename => "export.xlsx", :type => "application/vnd.ms-excel" )
  end

  private

    def bestellrunde_params
      params.require(:bestellrunde).permit()
    end
end

