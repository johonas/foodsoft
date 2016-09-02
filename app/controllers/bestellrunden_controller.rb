class BestellrundenController < InheritedResources::Base
  before_filter :authenticate_verteilen, :except => :for_depot


  def index
    @bestellrunden = Bestellrunde.order('id desc').all
  end

  def distribution_export
    filename = "bestellrunde_#{bestellrunde.starts}.xlsx"
    Reports::Bestellrunde.new(bestellrunde, filename).generate.send(self)
  end

  def depot_export
    depot = Depot.find(params[:depot_id])
    filename = "bestellrunde_#{bestellrunde.starts}_depot_#{depot.name.downcase.gsub(' ', '_')}.xlsx"

    begin
      Reports::BestellrundeDepot.new(bestellrunde, depot, filename).generate.send(self)
    rescue Reports::NoDataException
      redirect_to bestellrunden_path, flash: { error: I18n.t('report.no_data') }
    end
  end

  def for_depot
    @bestellrunde = Bestellrunde.find(params[:id])
    @ordergroup = current_user.ordergroup

    respond_to do |format|
      format.html { render partial: 'for_depot' }
      format.xlsx do

        filename = "#{I18n.t('bestellrunde.show.title') % { :label => @bestellrunde.label }}.xlsx".gsub(' ', '')
        Reports::BestellrundeDepotOverview.new(@bestellrunde, @ordergroup, filename).generate.send(self)
      end
    end

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

