require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  describe '#index' do
    it 'responds with a 200' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#loan_payments' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }
    let!(:payment) { Payment.create!(amount: 80.0, loan_id: loan.id) }

    it 'should return json of payments made for a loan' do
      get :loan_payments, params: { id: loan.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)[loan.id.to_s]).to be_an_instance_of(Array)
    end
  end

  describe '#loan_payment_info' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }
    let!(:payment) { Payment.create!(amount: 80.0, loan_id: loan.id) }

    it 'should return json of payment information for a loan' do
      get :loan_payment_info, params: { id: loan.id, payment_id: payment.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['payment_amount']).to eq payment.amount.to_s
    end

    it 'should return error if payment not found' do
      get :loan_payment_info, params: { id: loan.id, payment_id: 1000 }
      expect(JSON.parse(response.body)['error']).to eq 'Payment Not found'
    end
  end

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    it 'responds with a 200' do
      get :show, params: { id: loan.id }
      expect(response).to have_http_status(:ok)
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        get :show, params: { id: 10000 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'loan amount and payments made' do
      let(:loan) { Loan.create!(funded_amount: 1000.0) }
      let!(:payment) { Payment.create!(amount: 100.0, loan_id: loan.id) }
      let(:outstanding_balance) { loan.funded_amount - loan.total_loan_payments}

      it 'should return json object with loan amount and outstanding balance' do
        get :show, params: { id: loan.id }
        expect(JSON.parse(response.body)['loan_funded']).to eq loan.funded_amount.to_s
        expect(JSON.parse(response.body)['outstanding_balance']).to eq outstanding_balance.to_s
      end
    end
  end

  describe '#create' do
    let(:loan) { Loan.create!(funded_amount: 1000.0) }

    it 'responds with a 200' do
      post :create, params: { id: loan.id, amount: 100 }
      expect(response).to have_http_status(:ok)
    end

    context 'if given amount is 0 or less than 0' do
      it 'return return error response' do
        post :create, params: { id: loan.id, amount: 0 }
        expect(JSON.parse(response.body)["status"]).to eq 'error'
        expect(JSON.parse(response.body)["message"]).to eq 'Please enter amount greater than zero'
      end
    end

    context 'if given amount exceeds the outstanding balance of a loan' do
      let(:loan) { Loan.create!(funded_amount: 100.0) }
      let!(:payment) { Payment.create!(amount: 100.0, loan_id: loan.id) }
      let(:amount) { 10 }

      it 'return error response' do
        post :create, params: { id: loan.id, amount: amount }
        expect(JSON.parse(response.body)["status"]).to eq 'error'
        expect(JSON.parse(response.body)["message"]).to eq "Given payment amount #{amount.to_d} exceed the outstanding balance for loan #{loan.id}"
      end
    end

    context 'if given amount less than the outstanding balance of a loan' do
      let(:loan) { Loan.create!(funded_amount: 100.0) }
      let!(:payment) { Payment.create!(amount: 80.0, loan_id: loan.id) }
      let(:amount) { 10 }

      it 'return Success response and create payment' do
        post :create, params: { id: loan.id, amount: amount }
        expect(JSON.parse(response.body)["status"]).to eq 'success'
        expect(JSON.parse(response.body)["message"]).to eq "Payment of #{amount.to_d} has made successfully for loan #{loan.id}"
      end
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        post :create, params: { id: 10000 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
