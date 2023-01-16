require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'The merchant invoice show page', type: :feature do
  let(:merchant_1) { create(:merchant_with_invoices) }
  let(:merchant_2) { create(:merchant_with_invoices) }

  describe "I visit one of my merchant's invoice show pages" do
    it "Displays information about that invoice" do
      merchant_1.invoices.each do |invoice|
        visit merchant_invoice_path(merchant_1, invoice)

        expect(page).to have_content("Invoice ##{invoice.id}")
        expect(page).to have_content("Status: #{invoice.status}")
        expect(page).to have_content("Created at: #{invoice.created_at.strftime("%A, %B %-d, %Y")}")
        expect(page).to have_content("Customer: #{invoice.customer.first_name} #{invoice.customer.last_name}")
      end
    end

    it "Displays a list of all that invoice's items with my merchant and their details" do
      merchant_1.invoices.group(:id).each do |invoice|
        visit merchant_invoice_path(merchant_1, invoice)
        within "#items" do
          expect(page).to have_content('Items on this Invoice:')
          invoice.items.each do |item|
            within "#item-#{item.id}" do
              expect(page).to have_content("#{item.name}")
              expect(page).to have_content("#{item.invoice_items.where(invoice_id: invoice.id).first.quantity}")
              expect(page).to have_content("#{number_to_currency((item.invoice_items.where(invoice_id: invoice.id).first.unit_price)/100.00)}")
            end
          end
          merchant_2.invoices.group(:id).each do |invoice|
            invoice.items.each do |item|
              expect(page).not_to have_content(item.name)
            end
          end
        end
      end
    end

    it 'displays the total revenue that will be generated from all of my items on the invoice' do
      merchant_3 = create(:merchant)
      invoice_1 = create(:invoice_with_items, item_count: 2, ii_qty: 5, ii_price: 3000, merchant: merchant_3)
      invoice_2 = create(:invoice_with_items, item_count: 3, ii_qty: 2, ii_price: 2500, merchant: merchant_3)

      visit merchant_invoice_path(merchant_3, invoice_1)

      expect(page).to have_content("Total revenue: $300.00")

      visit merchant_invoice_path(merchant_3, invoice_2)

      expect(page).to have_content("Total revenue: $150.00")
    end

    it 'has a status drop down for each status with a default selection of the current status' do
      invoice = merchant_1.invoices.first

      visit merchant_invoice_path(merchant_1, invoice)

      invoice.items.each do |item|
        within "#item-#{item.id}" do
          expect(page).to have_select('invoice_item[status]', selected: item.invoice_item_by_invoice(invoice).status)
          expect(page).to have_select('invoice_item[status]', options: ['', 'pending','packaged', 'shipped'])
        end
      end
    end

    it "has a button to 'Update Item Status' which updates the invoice item status when clicked" do
      invoice = merchant_1.invoices.first
      item_1 = invoice.items.first

      visit merchant_invoice_path(merchant_1, invoice)

      invoice.items.each do |item|
        within "#item-#{item.id}" do
          expect(page).to have_button 'Update Item Status'
        end
      end

      within "#item-#{item_1.id}" do
        select 'packaged', from: 'invoice_item[status]'
        click_button('Update Item Status')
      end

      expect(current_path).to eq(merchant_invoice_path(merchant_1, invoice))

      within "#item-#{item_1.id}" do
        expect(page).to have_select('invoice_item[status]', selected: 'packaged')
      end

      expect(item_1.invoice_item_by_invoice(invoice).status).to eq('packaged')

      within "#item-#{item_1.id}" do
        select '', from: 'invoice_item[status]'
        click_button('Update Item Status')
      end

      expect(page).to have_content("Status can't be blank")
    end

    describe 'bulk discounts' do

      let!(:merchant_4) { Merchant.create!(name: "Jim") }
      let!(:item_2) { merchant_4.items.create!(name: "Pens", description: "For Writing", unit_price: 200) }
      let!(:item_3) { merchant_4.items.create!(name: "Paper", description: "The other thing you need for writing", unit_price: 400) }
  
      let!(:bk_1) { merchant_4.bulk_discounts.create!(discount: 20, quantity_threshold: 15) }
      let!(:bk_2) { merchant_4.bulk_discounts.create!(discount: 30, quantity_threshold: 20) }
  
      let!(:merchant_5) { Merchant.create!(name: "Charlie") }
      let!(:item_4) { merchant_5.items.create!(name: "Candy", description: "Chocolatey", unit_price: 500) }
  
      let!(:bk_3) { merchant_5.bulk_discounts.create!(discount: 10, quantity_threshold: 5) }
  
      let!(:cust_1) { Customer.create!(first_name: "Kamee", last_name: "Moore") }
      let!(:cust_2) { Customer.create!(first_name: "Ozzie", last_name: "Jones") }
  
      let!(:invoice_3) { cust_1.invoices.create!(status: 1) }
      let!(:ii_1) { InvoiceItem.create!(quantity: 10, unit_price: 200, status: 2, item_id: item_2.id, invoice_id: invoice_3.id) }
      let!(:ii_2) { InvoiceItem.create!(quantity: 20, unit_price: 400, status: 2, item_id: item_3.id, invoice_id: invoice_3.id) }
      let!(:ii_4) { InvoiceItem.create!(quantity: 3, unit_price: 500, status: 2, item_id: item_4.id, invoice_id: invoice_3.id) }
  
      let!(:invoice_4) { cust_2.invoices.create!(status: 1) }
      let!(:ii_3) { InvoiceItem.create!(quantity: 4, unit_price: 500, status: 2, item_id: item_4.id, invoice_id: invoice_4.id) }
  
      let!(:transaction_1) { invoice_3.transactions.create!(credit_card_number: 4536896898764278, credit_card_expiration_date: '12/24', result: 1) }
      let!(:transaction_2) { invoice_4.transactions.create!(credit_card_number: 4886443388914010, credit_card_expiration_date: '2/34', result: 1) }
  
      it 'displays the total revenue that will be generated from all of my items on the invoice with no discounts' do
        visit merchant_invoice_path(merchant_4, invoice_3)

        expect(page).to have_content("Total revenue: $100.00")
        
        visit merchant_invoice_path(merchant_5, invoice_3)

        expect(page).to have_content("Total revenue: $15.00")
      end
  
      it 'also shows the total revenue after bulk discounts have been applied' do 
        visit merchant_invoice_path(merchant_4, invoice_3)

        expect(page).to have_content("Total Revenue with Discounts: $76.00")

        visit merchant_invoice_path(merchant_5, invoice_3)
 
        expect(page).to have_content("Total revenue: $15.00")
      end

      it 'will have a link to the bulk discount show page if the invoice item qualifies' do 
        visit merchant_invoice_path(merchant_4, invoice_3)

        within "#invoice_item_#{ii_2.id}" do
          expect(page).to have_content(item_3.name)
          click_link "View this Bulk Discount"
          expect(current_path).to eq merchant_bulk_discount_path(merchant_4, bk_2)
        end 
      end

      it 'will have a message display if invoice item did not qualify for a bulk discount' do 
        visit merchant_invoice_path(merchant_4, invoice_3)

        within "#invoice_item_#{ii_1.id}" do
          expect(page).to have_content(item_2.name)
          expect(page).to have_content("This invoice item did not qualify for a discount")
        end 

        within "#invoice_item_#{ii_4.id}" do
          expect(page).to have_content(item_4.name)
          expect(page).to have_content("This invoice item did not qualify for a discount")
        end 
      end
    end
  end
end
