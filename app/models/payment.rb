class Payment < ActiveRecord::Base

  belongs_to :loan

  def self.total_payments_amount_for_loan(loan)
    payments = loan.payments
    payments ? payments.sum(:amount) : 0.0
  end
end