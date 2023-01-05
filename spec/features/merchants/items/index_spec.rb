require 'rails_helper'

RSpec.describe 'The merchant items index page', type: :feature do

  let!(:merchant_1) { create(:merchant_with_items) }
  let!(:merchant_2) { create(:merchant_with_items) }
  let!(:item_9) { create(:item, :disabled, merchant: merchant_2) }

  describe 'when a user visits a merchants items index page' do
    it 'displays all the names of a merchants items' do
      visit merchant_items_path(merchant_1)

      expect(page).to have_content "Item_1"
      expect(page).to have_content "Item_2"
      expect(page).to have_content "Item_3"
      expect(page).to have_content "Item_4"
      expect(page).to_not have_content "Item_5"

      visit merchant_items_path(merchant_2)

      expect(page).to_not have_content "Item_1"
      expect(page).to_not have_content "Item_2"
      expect(page).to_not have_content "Item_3"
      expect(page).to_not have_content "Item_4"
      expect(page).to have_content "Item_5"
    end
    
    it 'each name is a link to the item show page' do
      visit merchant_items_path(merchant_1)

      merchant_1.items.each do |item|
        expect(page).to have_link item.name, href: merchant_item_path(merchant_1, item)
      end
    end

    describe 'enabling and disabling items' do
      it 'has a button to disable or enable each item' do
        visit merchant_items_path(merchant_1)

        within("#item_1") do
          expect(page).to have_button "Enable"
        end

        within("#item_5") do
          expect(page).to have_button "Disable"
        end
      end

      it 'can change an items status and return to the index page' do
        item = merchant.items.first
        visit merchant_items_path(merchant_1)
        
        within("#item_1") do
          click_button "Enable"
        end

        expect(current_path).to eq merchant_items_path(merchant_1)
        
        within("#item_1") do
          expect(page).to have_button "Disable"
        end

        expect(item.status).to eq "enabled"
      end
    end
  end
end