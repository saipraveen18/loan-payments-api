class LoansController < ActionController::API

  before_action :find_loan, only: [:create, :show]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: 'not_found', status: :not_found
  end

  def index
    all_payments_made = []
    loans = Loan.includes(:payments).all
    loans.each do |loan|
      loan.payments.each do |payment|
        balance = loan.funded_amount - payment.amount
        all_payments_made << {payment_id: payment.id, loan_id: loan.id, balance: balance, date: payment.created_at}
      end
    end
    render json: all_payments_made.to_json
  end

  def show
    if @loan
      loan_given = @loan.funded_amount
      outstanding_balance = loan_given - Payment.total_payments_amount_for_loan(@loan)
      render json: {total_loan_amount: loan_given, outstanding_balance: outstanding_balance }.to_json
    else
      render json: {status: 'error'}
    end
  end

  def create
    permit_params
    given_amount = params[:amount].to_d
    if given_amount > 0
      total_payment_amount = Payment.total_payments_amount_for_loan(@loan)
      if given_amount <= (@loan.funded_amount - total_payment_amount)
        Payment.create(amount: given_amount)
        render json: {status: :success, message: 'Payment created successfully'}
      else
        render json: {status: :error, message: 'Given amount exceed the outstanding balance of a loan'}
      end
    else
      render json: {status: :error, message: 'Please enter amount greater than zero'}
    end
  end

  def permit_params
    params.permit(:id, :amount)
  end

  def find_loan
    @loan = Loan.find(params[:id])
  end
end
