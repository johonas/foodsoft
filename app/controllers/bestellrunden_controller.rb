class BestellrundenController < ApplicationController
  before_filter :authenticate_verteilen, :except => :for_depot

  def index
    @bestellrunden = Bestellrunde.where(id: Order.pluck(:bestellrunde_id)).order('id desc').all
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

  def supplier_export
    supplier = Supplier.find(params[:supplier_id])
    filename = "bestellrunde_#{bestellrunde.starts}_lieferant_#{supplier.name.downcase.gsub(' ', '_')}.xlsx"

    begin
      Reports::BestellrundeSupplier.new(bestellrunde, supplier, filename).generate.send(self)
    rescue Reports::NoDataException
      redirect_to bestellrunden_path, flash: { error: I18n.t('report.no_data') }
    end
  end

  def all_supplier_export
    xls_zip = XlsZip.new("bestellrunde_#{bestellrunde.starts}_alle_lieferanten")

    bestellrunde.suppliers.having_articles.each do |supplier|
      filename = "bestellrunde_#{bestellrunde.starts}_lieferant_#{supplier.name.downcase.gsub(' ', '_')}.xlsx"
      xls = Reports::BestellrundeSupplier.new(bestellrunde, supplier, filename).generate
      xls_zip.add_file(xls)
    end

    send_data xls_zip.data, filename: xls_zip.zip_name, type: xls_zip.content_type
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

