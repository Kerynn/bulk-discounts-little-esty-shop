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
        expect(page).to have_content("Percent Discount: #{bk_1.discount}%")
        expect(page).to have_content("Quantity Threshold: #{bk_1.quantity_threshold} items")
      end

      within "#bk_discount_#{bk_2.id}" do 
      expect(page).to have_content("Percent Discount: #{bk_2.discount}%")
      expect(page).to have_content("Quantity Threshold: #{bk_2.quantity_threshold} items")
    end 

      within "#bk_discount_#{bk_3.id}" do 
      expect(page).to have_content("Percent Discount: #{bk_3.discount}%")
      expect(page).to have_content("Quantity Threshold: #{bk_3.quantity_threshold} items")
    end

      expect(page).to_not have_content(bk_4.id)
    end

    it "has a link to each bulk discount's show page" do
      visit merchant_bulk_discounts_path(merchant_1)

      within "#bk_discount_#{bk_1.id}" do 
        expect(page).to have_link "#{bk_1.id}", href: merchant_bulk_discount_path(merchant_1, bk_1)
        click_link bk_1.id
      end

      expect(current_path).to eq merchant_bulk_discount_path(merchant_1, bk_1)

      visit merchant_bulk_discounts_path(merchant_1)

      within "#bk_discount_#{bk_2.id}" do 
        expect(page).to have_link "#{bk_2.id}", href: merchant_bulk_discount_path(merchant_1, bk_2)
      end 

      within "#bk_discount_#{bk_3.id}" do 
        expect(page).to have_link "#{bk_3.id}", href: merchant_bulk_discount_path(merchant_1, bk_3)
      end
    end

    it 'shows the next 3 us holidays with dates on the bulk index page' do 
      visit merchant_bulk_discounts_path(merchant_1)

      within "#national_holidays" do 
        expect(page).to have_content("National Holidays:")
        expect(page).to have_content("Martin Luther King, Jr. Day: 2023-01-16")
        expect(page).to have_content("Washington's Birthday: 2023-02-20")
        expect(page).to have_content("Good Friday: 2023-04-07")
      end
    end
  end 
end 