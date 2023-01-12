class Merchants::InvoicesController < ApplicationController

  def index
    merchant
    @invoices = @merchant.invoices
    @invoices = @merchant.invoices.indexed
  end

  def show
    merchant
    @invoice = Invoice.find(params[:id])
    @items = @invoice.items
  end

  private

  def merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
