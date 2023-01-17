require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Admin Invoice Show Page' do
    before(:each) do
        @invoice_1 = create(:invoice)
        @invoice_item = create(:invoice_item, invoice: @invoice_1)
    end

    describe 'When I visit an admin invoice show page' do
        it 'has information related to that invoice' do
            visit admin_invoice_path(@invoice_1)

            expect(page).to have_content("Invoice ##{@invoice_1.id}")
            expect(page).to have_content("Status:")
            expect(page).to have_content("Created at: #{@invoice_1.created_at.strftime("%A, %B%e, %Y")}")
            expect(page).to have_content("Customer: #{@invoice_1.customer.first_name} #{@invoice_1.customer.last_name}")
        end

        it 'has all the items on the invoice and their properties' do
            visit admin_invoice_path(@invoice_1)

            within "#items" do
                expect(page).to have_content('Items on this Invoice:')
                @invoice_1.items.each do |item|
                    within "#item-#{item.id}" do
                        expect(page).to have_content("#{item.name}")
                        expect(page).to have_content("#{item.invoice_items.where(invoice_id: @invoice_1.id).first.quantity}")
                        expect(page).to have_content("#{number_to_currency((item.invoice_items.where(invoice_id: @invoice_1.id).first.unit_price)/100.00)}")
                        expect(page).to have_content("#{item.invoice_items.where(invoice_id: @invoice_1.id).first.status}")
                    end
                end
            end
        end

        it 'displays the total revenue generated from this invoice' do
            visit admin_invoice_path(@invoice_1)

            expect(page).to have_content("Total Revenue: #{number_to_currency(@invoice_1.total_revenue / 100.00)}")
        end

        it 'has invoice status as a select field and the current status is selected' do
            visit admin_invoice_path(@invoice_1)

            expect(page).to have_select('invoice[status]', selected: "#{@invoice_1.status}")
            expect(page).to have_select('invoice[status]', options: ['','in progress', 'cancelled', 'completed'])
        end

        it "has a button to 'Update Invoice Status' which updates the invoice status when clicked" do
            visit admin_invoice_path(@invoice_1)

            expect(@invoice_1.status).to eq('in progress')

            select('completed', from: 'invoice[status]')
            click_button('Update Invoice Status')

            @invoice_1.reload
            
            expect(@invoice_1.status).to eq('completed')
            expect(page).to have_select('invoice[status]', selected: 'completed')
        
            expect(current_path).to eq(admin_invoice_path(@invoice_1))
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
                visit admin_invoice_path(invoice_3)
      
                expect(page).to have_content("Total Revenue: $115.00")

                visit admin_invoice_path(invoice_4)

                expect(page).to have_content("Total Revenue: $20.00")
            end
        
            it 'also shows the total revenue after bulk discounts have been applied' do 
                visit admin_invoice_path(invoice_3)
      
                expect(page).to have_content("Total Revenue with Discounts: $91.00")

                visit admin_invoice_path(invoice_4)

                expect(page).to have_content("Total Revenue with Discounts: $20.00")
            end
        end
    end
end
