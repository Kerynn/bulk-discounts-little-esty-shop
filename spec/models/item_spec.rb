require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:customers).through(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
    it { should validate_numericality_of :unit_price }
  end

  describe 'instance methods' do
    describe '#invoice_items_by_invoice' do
      it 'returns an items invoice items based on a specific invoice' do
        invoice_1 = create(:invoice)
        invoice_2 = create(:invoice)
        item_1 = create(:item)
        item_2 = create(:item)
        ii_1 = create(:invoice_item, item: item_1, invoice: invoice_1)
        ii_2 = create(:invoice_item, item: item_2, invoice: invoice_2)

        expect(item_1.invoice_item_by_invoice(invoice_1)).to eq(ii_1)
        expect(item_1.invoice_item_by_invoice(invoice_1)).not_to eq(ii_2)
        expect(item_2.invoice_item_by_invoice(invoice_2)).to eq(ii_2)
        expect(item_2.invoice_item_by_invoice(invoice_2)).not_to eq(ii_1)
      end
    end
  end
end
