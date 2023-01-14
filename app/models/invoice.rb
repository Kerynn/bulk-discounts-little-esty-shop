class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :transactions
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants
  
  enum status: ['in progress', 'completed', 'cancelled']

  scope :has_successful_transaction, -> { joins(:transactions).where(transactions: {result: 'success'})}

  scope :indexed, -> { distinct.order(:id) }

  def total_revenue
    self.invoice_items.sum('quantity*unit_price')
  end
  
  def self.incomplete_invoices
    self.joins(:invoice_items).where.not(invoice_items: { status: 2 }).order(:created_at).distinct
  end

  def invoice_discount
  invoice_items.joins(:bulk_discounts)
    .where('invoice_items.quantity >= bulk_discounts.quantity_threshold')
    .select('invoice_items.id, max((bulk_discounts.discount / 100.0) * (invoice_items.quantity * invoice_items.unit_price)) as total_discount')
    .group('invoice_items.id')
    .sum(&:total_discount)
  end

  def total_discounted_revenue
    total_revenue - invoice_discount
  end
end
