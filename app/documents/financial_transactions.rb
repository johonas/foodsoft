# encoding: utf-8
class FinancialTransactions < OrderPdf
  include ApplicationHelper

  def initialize(ordergroup, financial_transactions, from, to, options = nil)
    @ordergroup = ordergroup
    @financial_transactions = financial_transactions.unscope(:order).order('created_on ASC')
    @from = from || @financial_transactions.first.created_on
    @to = to || @financial_transactions.last.created_on

    super(options)
  end

  def filename
    I18n.t('documents.financial_transaction.filename', name: filename_safe(@ordergroup.name)) + '.pdf'
  end

  def title
    I18n.t('documents.financial_transaction.title', name: @ordergroup.name)
  end

  def body
    dimrows = [1]
    rows = [header_row]

    balance = @ordergroup.account_balance_on(@from - 1.day)
    rows << ['', '', I18n.t('documents.financial_transaction.opening_balance'), '', '', format_currency(balance)]

    @financial_transactions.includes(:user, :ordergroup).each do |t|
      amount = t.amount

      balance += amount

      credit = amount >= 0 ? amount : nil
      debit =  amount < 0 ? amount * -1 : nil

      rows << [
        format_date(t.created_on),
        show_user(t.user),
        t.note,
        format_currency(credit),
        format_currency(debit),
        format_currency(balance)
      ]
    end

    nice_table table_name, rows, dimrows do |table|
      table.row(0).font_style = :bold

      table.columns(-3..-1).align = :right

      @financial_transactions.count.times do |index|
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

  def table_name
    I18n.t('documents.financial_transaction.table_name', from: format_date(@from), to: format_date(@to))
  end

  def format_currency(value)
    if value
      number_to_currency(value, unit: '', separator: '.', delimiter: "’")
    end
  end
end
