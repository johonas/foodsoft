# encoding: utf-8
class ArticleStockChangesController < ApplicationController
  def new
    @article_stock_change = ArticleStockChange.new(article_id: params[:article_id])
    render action: :new, :layout => false
  end

  def create
    @article_stock_change = ArticleStockChange.new(article_stock_change_params)


    if @article_stock_change.valid? && @article_stock_change.save
      @article = @article_stock_change.article
      @supplier = @article_stock_change.article.supplier
      render template: 'articles/update', layout: false
    else
      render action: :new, layout: false
    end
  end

  private

  def article_stock_change_params
    { created_by: current_user }.merge(params[:article_stock_change])
  end
end
