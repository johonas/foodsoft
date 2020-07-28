# encoding: utf-8
class FinancialTransactions < OrderPdf
  include ApplicationHelper

  def initialize(financial_transactions, from, to, options = nil)
    @financial_transactions = financial_transactions.unscope(:order)
                                                    .joins(:ordergroup)
                                                    .includes(:ordergroup)
                                                    .order('groups.name, financial_transactions.created_on ASC')

    @from = from || @financial_transactions.first.created_on
    @to = to || @financial_transactions.last.created_on

    super(options)
  end

  def filename
    I18n.t('documents.financial_transaction.filename', from: format_date(@from), to:  format_date(@to)) + '.pdf'
  end

  def title
    I18n.t('documents.financial_transaction.title')
  end

  def body
    rows = nil
    balance = nil
    ordergroup = nil

    @financial_transactions.each do |financial_transaction|
      next if financial_transaction.ordergroup.deleted? || !financial_transaction.ordergroup.active

      if ordergroup != financial_transaction.ordergroup
        if ordergroup
          add_table(ordergroup, rows)
          start_new_page
        end

        ordergroup = financial_transaction.ordergroup

        rows = [header_row]
        balance = ordergroup.account_balance_on(@from - 1.day)
        rows << ['', '', I18n.t('documents.financial_transaction.opening_balance'), '', '', format_currency(balance)]
      end

      amount = financial_transaction.amount

      balance += amount

      credit = amount >= 0 ? amount : nil
      debit =  amount < 0 ? amount * -1 : nil

      rows << [
        format_date(financial_transaction.created_on),
        show_user(financial_transaction.user),
        financial_transaction.note,
        format_currency(credit),
        format_currency(debit),
        format_currency(balance)
      ]
    end

    add_table(ordergroup, rows)
  end

  def add_table(ordergroup, rows)
    nice_table table_name(ordergroup), rows, [1] do |table|
      table.row(0).font_style = :bold

      table.columns(-3..-1).align = :right
      table.column(0).width = 60
      table.column(-1).width = 47
      table.column(-2).width = 49
      table.column(-3).width = 50

      rows.length.times do |index|
        row_index = index + 2
        table.row(row_index).border_width = 0
        if row_index % 2 == 0
          table.row(row_index).background_color = 'eeeeee'
        end
      end
    end
  end

  def header_row
    [
      FinancialTransaction.human_attribute_name(:created_on),
      FinancialTransaction.human_attribute_name(:user),
      FinancialTransaction.human_attribute_name(:note),
      I18n.t('documents.financial_transaction.credit'),
      I18n.t('documents.financial_transaction.debit'),
      I18n.t('documents.financial_transaction.balance')
    ]
  end

  def table_name(ordergroup)
    I18n.t('documents.financial_transaction.table_name', ordergroup: ordergroup.name, from: format_date(@from), to: format_date(@to))
  end

  def format_currency(value)
    if value
      number_to_currency(value, unit: '', separator: '.', delimiter: "’")
    end
  end
end
