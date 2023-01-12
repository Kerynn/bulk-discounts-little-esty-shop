class Merchants::BulkDiscountsController < ApplicationController

  def index 
    merchant
  end

  private

  def merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
