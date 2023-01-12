require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many :items }
    it { should have_many(:invoice_items).through(:items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:customers).through(:invoices) }
    it { should have_many(:transactions).through(:invoices) }
    it { should have_many :bulk_discounts }
  end

  describe "validations" do
    it { should validate_presence_of :name }
  end

  let!(:merchant_1) { Merchant.create!(name: "KDavis", status: 0) }
  let!(:merchant_2) { create(:merchant) }
  let!(:merchant_3) { create(:merchant) }
  let!(:merchant_4) { create(:merchant) }
  let!(:merchant_5) { create(:enabled_merchant) }
  let!(:merchant_6) { create(:enabled_merchant) }
  let!(:merchant_7) { create(:enabled_merchant) }


  describe 'instance methods' do
    describe '#top_customers' do
      it 'returns the top 5 customers with the most successful transactions' do
        mer1 = create(:merchant)
        mer2 = create(:merchant)
        cus1 = create(:customer_with_success_trans, merchant: mer1, inv_count: 3)
        cus2 = create(:customer_with_success_trans, merchant: mer1, inv_count: 4)
        cus3 = create(:customer_with_success_trans, merchant: mer1, inv_count: 1)
        cus4 = create(:customer_with_success_trans, merchant: mer1, inv_count: 2)
        cus5 = create(:customer_with_success_trans, merchant: mer1, inv_count: 5)
        cus6 = create(:customer_with_success_trans, merchant: mer1, inv_count: 6)
        cus2_invoices = 5.times { create(:invoice_with_transactions, merchant: mer2, customer: cus2)}
        cus2_unsuccesful_invoices = 5.times { create(:invoice_with_transactions, merchant: mer1, customer: cus2, invoice_has_success: false) }
        inv_a = cus2.invoices.distinct[0]
        inv_b = cus2.invoices.distinct[1]
        item_a = cus2.invoices.distinct[0].items[0]
        item_b = cus2.invoices.distinct[1].items[0]
        create(:invoice_item, item: item_a, invoice: inv_b)
        create(:invoice_item, item: item_b, invoice: inv_a)
        
        expect(mer1.top_customers).to eq([cus6, cus5, cus2, cus1, cus4])
      end
    end

    describe '#customer_amount_of_successful_transactions' do
      it 'returns the number of successful transactions a customer has with this merchant' do
        mer1 = create(:merchant)
        mer2 = create(:merchant)
        cus1 = create(:customer_with_success_trans, merchant: mer1, inv_count: 3)
        cus2 = create(:customer_with_success_trans, merchant: mer1, inv_count: 4)
        cus3 = create(:customer_with_success_trans, merchant: mer1, inv_count: 1)
        cus4 = create(:customer_with_success_trans, merchant: mer1, inv_count: 2)
        cus5 = create(:customer_with_success_trans, merchant: mer1, inv_count: 5)
        cus6 = create(:customer_with_success_trans, merchant: mer1, inv_count: 6)
        cus2_invoices = 5.times { create(:invoice_with_transactions, merchant: mer2, customer: cus2)}
        cus2_unsuccesful_invoices = 5.times { create(:invoice_with_transactions, merchant: mer1, customer: cus2, invoice_has_success: false)}
        inv_a = cus2.invoices.distinct[0]
        inv_b = cus2.invoices.distinct[1]
        item_a = cus2.invoices.distinct[0].items[0]
        item_b = cus2.invoices.distinct[1].items[0]
        create(:invoice_item, item: item_a, invoice: inv_b)
        create(:invoice_item, item: item_b, invoice: inv_a)

        expect(mer1.customer_amount_of_successful_transactions(cus1.id)).to eq(3)
        expect(mer1.customer_amount_of_successful_transactions(cus2.id)).to eq(4)
        expect(mer1.customer_amount_of_successful_transactions(cus3.id)).to eq(1)
        expect(mer1.customer_amount_of_successful_transactions(cus4.id)).to eq(2)
        expect(mer1.customer_amount_of_successful_transactions(cus5.id)).to eq(5)
        expect(mer1.customer_amount_of_successful_transactions(cus6.id)).to eq(6)
      end
    end

    describe '#top_items' do
      it 'returns the top 5 items and their total revenue in ascending order by revenue for a merchant' do
        #factorybot revenue per invoice is 50000
        item_1 = create(:item_with_successful_transaction, number_of_invoices: 5, merchant: merchant_2)
        item_2 = create(:item_with_successful_transaction, number_of_invoices: 1, merchant: merchant_2)
        item_3 = create(:item_with_successful_transaction, number_of_invoices: 3, merchant: merchant_2)
        item_4 = create(:item_with_successful_transaction, number_of_invoices: 6, merchant: merchant_2)
        item_5 = create(:item_with_successful_transaction, number_of_invoices: 2, merchant: merchant_2)
        item_6 = create(:item_with_successful_transaction, number_of_invoices: 4, merchant: merchant_2)
        item_7 = create(:item_with_successful_transaction, number_of_invoices: 11, merchant: merchant_3)
        item_8 = create(:item_with_unsuccessful_transaction, number_of_invoices: 11, merchant: merchant_2)

        expect(merchant_2.top_items).to eq [item_4, item_1, item_6, item_3, item_5]
        expect(merchant_2.top_items[0].revenue).to eq 300000 
        expect(merchant_2.top_items[4].revenue).to eq 100000
      end
    end

    describe '#items_ready_to_ship' do
      it 'returns all items for a merchant that are packaged' do
        mer1 = create(:merchant)
        inv1 = create(:invoice_with_items, merchant: mer1)
        inv2 = create(:invoice_with_items, merchant: mer1)
        ii2_1 = create(:invoice_item, item: mer1.items.first, invoice: inv2, status: 1)
        3.times { create(:item, merchant: mer1) }

        expect(mer1.items_ready_to_ship).to eq([mer1.items.first, mer1.items.third])
      end
    end
  end

  describe 'class methods' do
    describe '#top 5 merchants' do
      it 'determines the top 5 merchants by total revenue with at least 1 successful transaction' do 
        4.times { create(:invoice_with_transactions, invoice_has_success: true, merchant: merchant_1, transaction_qty: 1)}

        3.times { create(:invoice_with_transactions, invoice_has_success: true, merchant: merchant_2, transaction_qty: 2)}

        2.times { create(:invoice_with_transactions, invoice_has_success: false, merchant: merchant_3, transaction_qty: 2)}
        create(:invoice_with_transactions, invoice_has_success: true, merchant: merchant_3, transaction_qty: 2)

        2.times { create(:invoice_with_transactions, invoice_has_success: true, merchant: merchant_4, transaction_qty: 1)}

        5.times { create(:invoice_with_transactions, invoice_has_success: true, merchant: merchant_5, transaction_qty: 2)}
        create(:invoice_with_transactions, invoice_has_success: false, merchant: merchant_5, transaction_qty: 2)

        6.times { create(:invoice_with_transactions, invoice_has_success: true, merchant: merchant_6, transaction_qty: 1)}

        create(:invoice_with_transactions, invoice_has_success: false, merchant: merchant_7, transaction_qty: 1)

        expect(Merchant.top_five_merchants).to eq([merchant_6, merchant_5, merchant_1, merchant_2, merchant_4])
      end

      it 'determines the top selling date for a merchant' do 
        merchant_1 = create(:merchant_with_dated_invoices, date_offset: 4.months)
        merchant_2 = create(:merchant_with_dated_invoices, date_offset: 2.years)

        expect(merchant_1.best_day.strftime("%A, %B %-d, %Y")).to eq("Thursday, September 8, 2022")
        expect(merchant_2.best_day.strftime("%A, %B %-d, %Y")).to eq("Friday, January 8, 2021")
      end
    end
  end
end
