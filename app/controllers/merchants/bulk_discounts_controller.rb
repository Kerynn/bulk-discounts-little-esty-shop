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

  def create 
    merchant 
    bulk_discount = merchant.bulk_discounts.new(bk_params)
    if bulk_discount.save(bk_params)
      redirect_to merchant_bulk_discounts_path(merchant)
    else 
      flash[:alert] = bulk_discount.errors.full_messages.to_sentence 
      redirect_to new_merchant_bulk_discount_path(merchant)
    end 
  end

  private

  def merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def bk_params 
    params.permit(:discount, :quantity_threshold)
  end
end
