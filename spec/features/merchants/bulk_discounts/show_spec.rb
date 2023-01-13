require 'rails_helper'

RSpec.describe 'Bulk Discount Show Page' do

  let!(:merchant_1) { create(:merchant) }
  let!(:bk_1) { merchant_1.bulk_discounts.create!(discount: 20, quantity_threshold: 10)}
  let!(:bk_2) { merchant_1.bulk_discounts.create!(discount: 10, quantity_threshold: 5)}

  describe 'when I visit a bulk discount show page' do 
    it "displays the bulk discount's quantity threshold and percentage discount" do 
      visit merchant_bulk_discount_path(merchant_1, bk_1)

      expect(page).to have_content(bk_1.id)
      expect(page).to have_content(bk_1.discount)
      expect(page).to have_content(bk_1.quantity_threshold)
      expect(page).to_not have_content(bk_2.id)
    end
  end 
end 