class Merchants::BulkDiscountsController < ApplicationController

  def index 
    merchant
    @bulk_discounts = merchant.bulk_discounts
  end

  def show 
    merchant 
    
  end

  def new 
    merchant
  end


  private

  def merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
