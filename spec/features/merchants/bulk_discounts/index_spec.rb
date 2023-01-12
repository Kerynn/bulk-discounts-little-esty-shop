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

    end

    xit "has a link to each bulk discounts' show page" do

    end
  end
end