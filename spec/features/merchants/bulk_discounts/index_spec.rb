require 'rails_helper'

RSpec.describe 'Bulk Discount Index Page' do

  let!(:merchant_1) { create(:merchant) }
  let!(:merchant_2) { create(:merchant) }

  let!(:bk_1) { merchant_1.bulk_discounts.create!(discount: 20, quantity_threshold: 10)}
  let!(:bk_2) { merchant_1.bulk_discounts.create!(discount: 10, quantity_threshold: 5)}
  let!(:bk_3) { merchant_1.bulk_discounts.create!(discount: 30, quantity_threshold: 20)}
  let!(:bk_4) { merchant_2.bulk_discounts.create!(discount: 15, quantity_threshold: 10)}

  describe 'when I visit my merchant dashboard' do 
    it 'has a link to view all my discounts on my discounts index page' do 
      visit "/merchants/#{merchant_1.id}/dashboard"

      click_link "View my Bulk Discounts"
    
      expect(current_path).to eq merchant_bulk_discounts_path(merchant_1)
    end

    it 'shows all my bulk discounts with their discount and quantity threshold' do 
      visit merchant_bulk_discounts_path(merchant_1)

      within "#bk_discount_#{bk_1.id}" do 
        expect(page).to have_content("Percent Discount: %#{bk_1.discount}")
        expect(page).to have_content("Quantity Threshold: #{bk_1.quantity_threshold} items")
      end

      within "#bk_discount_#{bk_2.id}" do 
      expect(page).to have_content("Percent Discount: %#{bk_2.discount}")
      expect(page).to have_content("Quantity Threshold: #{bk_2.quantity_threshold} items")
    end 

      within "#bk_discount_#{bk_3.id}" do 
      expect(page).to have_content("Percent Discount: %#{bk_3.discount}")
      expect(page).to have_content("Quantity Threshold: #{bk_3.quantity_threshold} items")
    end

      expect(page).to_not have_content(bk_4.id)
    end

    it "has a link to each bulk discounts' show page" do
      visit merchant_bulk_discounts_path(merchant_1)

      within "#bk_discount_#{bk_1.id}" do 
        expect(page).to have_link "#{bk_1.id}", href: merchant_bulk_discount_path(merchant_1, bk_1)
      end

      within "#bk_discount_#{bk_2.id}" do 
        expect(page).to have_link "#{bk_2.id}", href: merchant_bulk_discount_path(merchant_1, bk_2)
      end 

      within "#bk_discount_#{bk_3.id}" do 
        expect(page).to have_link "#{bk_3.id}", href: merchant_bulk_discount_path(merchant_1, bk_3)
      end
    end

    describe 'create a new discount' do 
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
          expect(page).to have_content("Percent Discount: %#{new_bk.discount}")
          expect(page).to have_content("Quantity Threshold: #{new_bk.quantity_threshold} items")    
        end
      end

      xit 'test for sad path.....' do 

      end
    end
  end
end