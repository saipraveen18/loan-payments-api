class Loan < ActiveRecord::Base
  has_many :payments

  def total_loan_payments
    payments ? payments.sum(:amount) : 0.0
  end
end