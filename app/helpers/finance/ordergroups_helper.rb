module Finance::OrdergroupsHelper
  def transactions_pdf(ordergroup, url_params, options = {})
    options = options.merge(
      title: t('helpers.finance.ordergroups.transactions_pdf'),
      class: 'btn'
    )

    url_params = (url_params || {}).merge(format: :pdf)

    if ordergroup
      url = finance_ordergroup_transactions_path(ordergroup, url_params)
    else
      url = url_for(url_params)
    end

    link_to url, options do
      glyph(:download) + ' ' + t('helpers.finance.ordergroups.transactions_pdf')
    end
  end
end
