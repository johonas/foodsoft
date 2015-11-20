require 'action_view'

class BestellrundeXls
  include ApplicationHelper

  def initialize(bestellrunde)
    @bestellrunde = bestellrunde
    @data = collect_data(bestellrunde)
  end

  def data
    default_format = Spreadsheet::Format.new :size => 13
    overview_format = Spreadsheet::Format.new :weight => :bold, :size => 10, :pattern_fg_color => :white, :pattern => 1
    header_format = Spreadsheet::Format.new :weight => :bold, :size => 15, :pattern_fg_color => :grey, :pattern => 1
    header_upright_format = Spreadsheet::Format.new :rotation => 90, :weight => :bold, :size => 13, :pattern_fg_color => :grey, :pattern => 1

    xls = Spreadsheet::Workbook.new
    @data.each do |depot, articles|
      collected_order_groups = []
      depot_total = 0

      depot_sheet = xls.create_worksheet :name => depot.name

      articles.each_with_index do |(article, order_groups), i|
        row = depot_sheet.row(i+3)
        row.default_format = default_format
        row.height = 20

        row.push article.name
        row.push article.supplier.name
        row.push article.unit_quantity
        row.push article.unit

        order_groups.each do |order_group, quantity|
          collected_order_groups << order_group
          row.push quantity
          depot_total += quantity
        end
        row.push depot_total
      end

      overview = depot_sheet.row(0)
      overview.default_format = overview_format
      overview.height = 20
      overview.push "foodcoop Comedor – Verteilliste: #{format_date(@bestellrunde.starts)} - #{format_date(@bestellrunde.ends)}"

      overview = depot_sheet.row(1)
      overview.default_format = overview_format
      overview.height = 20
      overview.push "QD: #{depot.name}"


      header = depot_sheet.row(2)
      header.height = 80
      header.default_format = header_format
      header.push "Produkt"
      header.push "HerstellerIn / LieferantIn"
      header.push "Gebinde"
      header.push "Einheit"

      collected_order_groups.each_with_index do |order_group, index|
        header.push order_group.name
        header.set_format((index + 4), header_upright_format)
      end

      header.push "Total Depot"
      header.set_format((collected_order_groups.length + 4), header_upright_format)

      depot_sheet.column(0).width = 20
      depot_sheet.column(1).width = 20
      depot_sheet.column(2).width = 10

    end

    file_contents = StringIO.new
    xls.write(file_contents)
    return file_contents
  end

  def collect_data(bestellrunde)
    data = {}
    bestellrunde.orders.each do |order|
      order.group_orders.each do |group_order|
        data[group_order.ordergroup.depot] = {} unless data.include?(group_order.ordergroup.depot)

        group_order.group_order_articles.each do |group_order_article|
          unless data[group_order.ordergroup.depot].include?(group_order_article.order_article.article)
            data[group_order.ordergroup.depot][group_order_article.order_article.article] = {}
          end

          data[group_order.ordergroup.depot][group_order_article.order_article.article][group_order.ordergroup] = group_order_article.quantity

        end

      end
    end



    return data
  end
end