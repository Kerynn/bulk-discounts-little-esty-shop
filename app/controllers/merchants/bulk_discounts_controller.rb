class Merchants::BulkDiscountsController < ApplicationController

  def index 
    merchant
    @bulk_discounts = merchant.bulk_discounts
    # @holidays = HolidaySearch.new.holidays 
  end

  def show 
    merchant
    @bk_discount = BulkDiscount.find(params[:id])
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

  def destroy 
    bk_discount = BulkDiscount.find(params[:id])
    bk_discount.destroy 
    redirect_to merchant_bulk_discounts_path(merchant)
  end

  def edit 
    merchant
    @bk_discount = BulkDiscount.find(params[:id])
  end

  def update 
    bk_discount = BulkDiscount.find(params[:id])
    if bk_discount.update(bk_params)
      flash[:alert] = "Bulk Discount Information Successfully Updated"
      redirect_to merchant_bulk_discount_path(merchant, bk_discount)
    else
      flash[:alert] = bk_discount.errors.full_messages.to_sentence 
      redirect_to edit_merchant_bulk_discount_path(merchant, bk_discount)
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
