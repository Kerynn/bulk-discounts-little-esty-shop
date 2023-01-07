class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  validates_presence_of :status
  enum status: ['pending', 'packaged', 'shipped']

  def revenue
    InvoiceItem.where(id: self.id).sum('quantity*unit_price')
  end
end
