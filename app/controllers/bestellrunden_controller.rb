class BestellrundenController < InheritedResources::Base

  before_filter :authenticate_verteilen

  def index
    @bestellrunden = Bestellrunde.all
  end

  def export
    bestellrunde = Bestellrunde.find(params[:id])
    xls = BestellrundeXls.new(bestellrunde)

    if xls.data.length > 0
      send_data(xls.spreadsheet_data.string.force_encoding('binary'), :filename => "export.xlsx", :type => "application/vnd.ms-excel" )
    else
      redirect_to bestellrunden_path, :alert => 'Es gibt keine Daten zu exportieren.'
    end
  end

  private

    def bestellrunde_params
      params.require(:bestellrunde).permit
    end
end

