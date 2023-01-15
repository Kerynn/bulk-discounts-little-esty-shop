class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_many :transactions, through: :invoice
  has_many :merchants, through: :item 
  has_many :bulk_discounts, through: :merchants 
  
  validates_presence_of :status
  enum status: ['pending', 'packaged', 'shipped']

  def revenue
    InvoiceItem.where(id: self.id).sum('quantity*unit_price')
  end

  def discounts 
    bulk_discounts.joins(:invoice_items)
    .where("invoice_items.quantity >= bulk_discounts.quantity_threshold AND invoice_items.item_id = items.id")
    .order(discount: :desc).first
  end
end
