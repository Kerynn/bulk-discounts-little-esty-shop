FactoryBot.define do
  factory :merchant do
    sequence(:name) { |n| "Merchant_#{n}" }

    factory :merchant_with_items do
      transient do
        num { 4 }
        item_name { 'default_item_name' }
      end

      before(:create) do |merchant, evaluator|
        evaluator.num.times do |t|
          create(:item, name: "#{evaluator.item_name}_#{t}", merchant: merchant)
        end
      end
    end

    factory :merchant_with_invoices do
      transient do
        item_num { 4 }
        invoice_num { 2 }
      end

      before(:create) do |merchant, evaluator|
        evaluator.item_num.times do |t|
          item = create(:item, merchant: merchant)
          invoice = create(:invoice)
          create(:invoice_item, item: item, invoice: invoice)
        end
      end
    end
  end
end
