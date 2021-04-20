class LoansController < ActionController::API

  before_action :find_loan, only: [:create, :show, :loan_payments, :loan_payment_info]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: 'not_found', status: :not_found
  end

  #renders a json of all loans and their respective payments
  def index
    loan_payments = {}
    loans = Loan.includes(:payments).all
    loans.each do |loan|
      loan.payments.each do |payment|
        balance_left = loan.funded_amount - payment.amount
        loan_payments[loan.id] ||= []
        loan_payments[loan.id] << { payment_id: payment.id, balance_left: balance_left, paid_amount: payment.amount, payment_made: payment.created_at }
      end
    end
    render json: loan_payments
  end

  #renders a json a payments made for a particular loan
  def loan_payments
    loan_payments = {}
    @loan.payments.each do |payment|
      balance_left = @loan.funded_amount - payment.amount
      loan_payments[@loan.id] ||= []
      loan_payments[@loan.id] << { payment_id: payment.id, balance_left: balance_left, paid_amount: payment.amount, payment_made: payment.created_at }
    end
    render json: loan_payments
  end

  #renders payment info for a particular loan and particular payment
  def loan_payment_info
    payment = @loan.payments.where(id: params[:payment_id]).last
    render json: { error: "Payment Not found"} and return unless payment.present?

    render json: { loan_id: payment.loan.id, payment_amount: payment.amount, payment_made: payment.created_at}
  end

  #renders json object of total loan given and outstanding balance
  def show
    loan_funded = @loan.funded_amount
    outstanding_balance = loan_funded - @loan.total_loan_payments
    render json: { loan_funded: loan_funded, outstanding_balance: outstanding_balance }
  end

  def create
    new_payment_amount = params[:amount].to_d
    if new_payment_amount.present? && new_payment_amount <= 0.0
      render json: {status: :error, message: 'Please enter amount greater than zero'} and return
    end

    total_paid_amount = @loan.total_loan_payments
    if new_payment_amount <= (@loan.funded_amount - total_paid_amount)
      @loan.payments.create(amount: new_payment_amount)
      render json: {status: :success, message: "Payment of #{new_payment_amount} has made successfully for loan #{@loan.id}"}
    else
      render json: {status: :error, message: "Given payment amount #{new_payment_amount} exceed the outstanding balance for loan #{@loan.id}"}
    end
  end

  def find_loan
    @loan = Loan.find(params[:id])
  end
end
