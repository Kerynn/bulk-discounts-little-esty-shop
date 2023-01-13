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

    it 'has a link to a pre-populated form to edit the bulk discount' do 
      visit merchant_bulk_discount_path(merchant_1, bk_1)

      click_link "Update this Bulk Discount"

      expect(current_path).to eq edit_merchant_bulk_discount_path(merchant_1, bk_1)
      expect(page).to have_field('Discount', with: "#{bk_1.discount}")
      expect(page).to have_field('Quantity threshold', with: "#{bk_1.quantity_threshold}")
    end

    it 'shows the updates on the bulk discount show page once submitted' do 
      visit merchant_bulk_discount_path(merchant_1, bk_1)

      expect(page).to have_content("Quantity Threshold: 10 items")

      click_link "Update this Bulk Discount"

      fill_in 'Quantity threshold', with: 20
      click_button 'Save'

      expect(current_path).to eq merchant_bulk_discount_path(merchant_1, bk_1)
      expect(page).to have_content("Quantity Threshold: 20 items")
    end

    it 'shows a flash message if update was successful' do 
      visit merchant_bulk_discount_path(merchant_1, bk_1)

      expect(page).to have_content("Quantity Threshold: 10 items")

      click_link "Update this Bulk Discount"

      fill_in 'Quantity threshold', with: 20
      click_button 'Save'

      expect(current_path).to eq merchant_bulk_discount_path(merchant_1, bk_1)
      expect(page).to have_content("Quantity Threshold: 20 items")
      expect(page).to have_content("Bulk Discount Information Successfully Updated")
    end

    it 'shows an error message if update was not successful' do 
      visit merchant_bulk_discount_path(merchant_1, bk_1)

      expect(page).to have_content("Quantity Threshold: 10 items")

      click_link "Update this Bulk Discount"

      fill_in 'Quantity threshold', with: 'hello'
      click_button 'Save'

      expect(current_path).to eq edit_merchant_bulk_discount_path(merchant_1, bk_1)
      expect(page).to have_content("Quantity threshold is not a number")
    end
  end 
end 