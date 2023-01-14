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
end
