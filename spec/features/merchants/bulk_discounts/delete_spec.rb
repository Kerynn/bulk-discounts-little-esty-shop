require 'rails_helper'

RSpec.describe 'Delete a bulk discount from a merchant' do

  let!(:merchant_1) { create(:merchant) }

  let!(:bk_1) { merchant_1.bulk_discounts.create!(discount: 20, quantity_threshold: 10)}
  let!(:bk_2) { merchant_1.bulk_discounts.create!(discount: 10, quantity_threshold: 5)}
  let!(:bk_3) { merchant_1.bulk_discounts.create!(discount: 30, quantity_threshold: 20)}

  describe 'when I visit the merchant bulk discounts index page' do 
    it 'has a button to delete a discount next to each bulk discount' do 
      visit merchant_bulk_discounts_path(merchant_1)

      within "#bk_discount_#{bk_1.id}" do 
        expect(page).to have_button("Delete Discount #{bk_1.id}")
      end

      within "#bk_discount_#{bk_2.id}" do 
        expect(page).to have_button("Delete Discount #{bk_2.id}")
      end 

      within "#bk_discount_#{bk_3.id}" do 
        expect(page).to have_button("Delete Discount #{bk_3.id}")
      end
    end 

    it 'removes the discount when the delete discount button is clicked' do 
      visit merchant_bulk_discounts_path(merchant_1)

      expect(page).to have_content(bk_1.id)

      click_button "Delete Discount #{bk_1.id}"

      expect(current_path).to eq merchant_bulk_discounts_path(merchant_1)
      expect(page).to_not have_content(bk_1.id)

      expect(page).to have_content(bk_2.id)
      expect(page).to have_content(bk_3.id)
    end 
  end 
end 
