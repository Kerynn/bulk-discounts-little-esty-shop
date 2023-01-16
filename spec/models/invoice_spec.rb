require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it {should belong_to :customer}
    it {should have_many :invoice_items}
    it {should have_many(:items).through(:invoice_items)}
    it {should have_many :transactions}
    it {should have_many(:merchants).through(:items)}
    it {should have_many(:bulk_discounts).through(:merchants)}
  end

  describe 'class methods' do 
    describe 'incomplete_invoices' do 
      it 'returns the invoices with items not yet shipped in order from oldest to youngest' do 
        inv1 = create(:invoice_with_items, created_at: Date.new(2018,8,04))
        inv2 = create(:invoice_with_items, created_at: Date.new(2021,12,20))
        inv3 = create(:invoice_with_items, created_at: Date.new(2019,3,21))
        inv4 = create(:invoice)
        ii1 = create(:invoice_item, invoice: inv4, status: 2)
        ii2 = create(:invoice_item, invoice: inv4, status: 2)
      
        expect(Invoice.incomplete_invoices).to eq([inv1, inv3, inv2])
      end
    end
  end

  describe 'instance methods' do

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

    describe '#total_revenue' do
      it 'returns the total revenue for an invoice' do
        invoice_1 = create(:invoice_with_items, item_count: 2, ii_qty: 5, ii_price: 3000)
        invoice_2 = create(:invoice_with_items, item_count: 3, ii_qty: 2, ii_price: 2500)

        expect(invoice_1.total_revenue).to eq(30000)
        expect(invoice_2.total_revenue).to eq(15000)
        expect(invoice_3.total_revenue).to eq(11500)
      end
    end

    describe '#total_merchant_rev' do 
      it 'returns the total revenue for an invoice of a specific merchant' do 
        expect(invoice_3.total_merchant_rev(merchant_4)).to eq(10000)
        expect(invoice_3.total_merchant_rev(merchant_5)).to eq(1500)
      end
    end

    describe '#merchant_discount_amount' do 
      it 'returns the amount to be discounted from a merchant invoice' do 
        expect(invoice_3.merchant_discount_amount(merchant_4)).to eq(2400)
        expect(invoice_3.merchant_discount_amount(merchant_5)).to eq(0)
      end
    end 

    describe '#merchant_total_discounted_rev' do 
      it 'returns the total revenue for a merchant invoice after discounts' do 
        expect(invoice_3.merchant_total_discounted_rev(merchant_4)).to eq(7600)
        expect(invoice_3.merchant_total_discounted_rev(merchant_5)).to eq(1500)
      end
    end

    describe 'invoice_discount' do 
      it 'returns the amount to be discounted from an invoice' do 
        expect(invoice_3.invoice_discount).to eq(2400)
      end
    end 

    describe 'total_discounted_revenue' do 
      it 'returns the total revenue for an invoice after the discount has been applied' do 
        expect(invoice_3.total_discounted_revenue).to eq(9100)
      end
    end
  end 
end
