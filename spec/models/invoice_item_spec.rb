require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to :item }
    it { should belong_to :invoice }
    it { should have_many(:transactions).through(:invoice) }
    it { should have_many(:merchants).through(:item) }
    it { should have_many(:bulk_discounts).through(:merchants) }
  end

  describe 'validations' do
    it { should validate_presence_of :status }
  end

  describe 'instance methods' do
    describe '#revenue' do
      it 'returns the total revenue of the invoice item' do
        ii_1 = create(:invoice_item, quantity: 4, unit_price: 20000)
        ii_2 = create(:invoice_item, quantity: 10, unit_price: 12000)

        expect(ii_1.revenue).to eq(80000)
        expect(ii_2.revenue).to eq(120000)
      end
    end

    describe '#discounts' do 
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

      it 'will determine if an invoice item has a discount' do 
        expect(ii_2.discounts).to eq(bk_2)
        expect(ii_1.discounts).to eq nil
      end
    end
  end
end
