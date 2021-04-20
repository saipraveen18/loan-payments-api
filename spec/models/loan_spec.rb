require 'rails_helper'

RSpec.describe Loan, :type => :model do

  context '#total_loan_payments' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    context 'if no payments are made' do
      it 'should return amount 0 if no payments are made' do
        expect(loan.total_loan_payments).to eq 0.0
      end
    end

    context 'if payments are made' do
      let!(:payment) { Payment.create!(amount: 80.0, loan_id: loan.id) }
      it 'should return amount of total payments made' do
        expect(loan.total_loan_payments).to eq 80.0
      end
    end
  end
end
