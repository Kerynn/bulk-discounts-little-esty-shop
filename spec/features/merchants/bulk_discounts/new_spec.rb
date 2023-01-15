require 'rails_helper'

RSpec.describe 'Create a New Discount for a Merchant' do

  let!(:merchant_1) { create(:merchant) }

  describe 'when I visit the merchant dashboard page' do 
    it 'has a link to add a new bulk discount' do 
      visit merchant_bulk_discounts_path(merchant_1)

      click_link "Create a New Bulk Discount"

      expect(current_path).to eq new_merchant_bulk_discount_path(merchant_1)
    end

    it 'adds a new bulk discount to the bulk discount index page' do 
      visit new_merchant_bulk_discount_path(merchant_1)

      fill_in 'Discount', with: 25
      fill_in 'Quantity threshold', with: 5
      click_on 'Create New Discount'

      new_bk = BulkDiscount.last 
      expect(current_path).to eq merchant_bulk_discounts_path(merchant_1)

      within "#bk_discount_#{new_bk.id}" do 
        expect(page).to have_content(new_bk.id)
        expect(page).to have_content("Percent Discount: #{new_bk.discount}%")
        expect(page).to have_content("Quantity Threshold: #{new_bk.quantity_threshold} items")    
      end
    end

    it 'returns to the create new discount form page with error if not filled out correctly' do 
      visit new_merchant_bulk_discount_path(merchant_1)

      fill_in 'Discount', with: ''
      fill_in 'Quantity threshold', with: 5
      click_on 'Create New Discount'

      expect(current_path).to eq new_merchant_bulk_discount_path(merchant_1)
      expect(page).to have_content("Discount can't be blank")

      visit new_merchant_bulk_discount_path(merchant_1)

      fill_in 'Discount', with: 30
      fill_in 'Quantity threshold', with: 'hello there'
      click_on 'Create New Discount'

      expect(current_path).to eq new_merchant_bulk_discount_path(merchant_1)
      expect(page).to have_content("Quantity threshold is not a number")
    end
  end
end
