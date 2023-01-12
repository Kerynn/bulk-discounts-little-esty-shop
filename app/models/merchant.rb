class Merchant < ApplicationRecord
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :bulk_discounts

  validates_presence_of :name

  enum status: %w[disabled enabled]

  def top_customers
    # self.invoices.joins(:customer, :transactions).where(transactions: { result: 1 }).select('customers.*').group('customers.id').order('count(transactions) desc').limit(5)

    # Customer.joins(invoices: [:transactions, :items]).where(transactions: { result: 1 }).where(items: { merchant_id: self.id }).group(:id).order('count(transactions.*) desc').limit(5)
    
    # Transaction.joins(invoice: [:items, :customer]).where(result: 1).where(items: { merchant_id: self.id }).select('customers.*').group('customers.id').order('count(transactions) desc').limit(5)

    # Customer.select('customers.*, count(distinct transactions) as transaction_count')
    #         .joins(invoices: [:transactions, :items]).group(:id)
    #         .where(transactions: { result: 'success' })
    #         .where(items: { merchant_id: id })
    #         .order('transaction_count desc').limit(5)

    Customer.joins(invoices: [:transactions, :items]).where(transactions: { result: 1 }).where(items: { merchant_id: self.id }).group(:id).order('count(distinct transactions) desc').limit(5)
  end

  def customer_amount_of_successful_transactions(cus_id)
    # self.invoices.where(customer_id: cus_id).joins(:transactions).where(transactions: { result: 1 }).distinct.count

    Transaction.joins(invoice: [:items, :customer]).where(result: 1).where(items: { merchant_id: self.id }).where(customers: { id: cus_id }).distinct.count
  end

  def top_items
    self.items.joins(:invoices).merge(Invoice.has_successful_transaction).select('items.*, sum(invoice_items.quantity * invoice_items.unit_price) as revenue').group(
      'items.name', :id
    ).order(revenue: :desc).limit(5)
  end

  def self.top_five_merchants
    self.joins(:invoices, :transactions)
      .where(transactions: { result: 1 })
      .group(:id)
      .select('merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_rev')
      .order(total_rev: :desc).limit(5)
  end

  def items_ready_to_ship
    self.items.packaged.distinct
  end

  def best_day
    self.invoices.joins(:transactions)
    .where(transactions: {result: 1})
    .select('invoices.created_at', 'sum(invoice_items.quantity * invoice_items.unit_price) as total_day_revenue')
    .group(:created_at).order(total_day_revenue: :desc).first.created_at
  end
end
