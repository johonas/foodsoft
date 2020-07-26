module Finance::OrdergroupsHelper
  def transactions_pdf(ordergroup, url_params, options={})
    options = options.merge(
      title: t('helpers.finance.ordergroups.transactions_pdf'),
      class: 'btn'
    )

    url = finance_ordergroup_transactions_path(ordergroup, (url_params || {}).merge(format: :pdf))

    link_to url, options do
      glyph(:download) + ' ' + t('helpers.finance.ordergroups.transactions_pdf')
    end
  end
end
