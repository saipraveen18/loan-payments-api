require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  describe '#index' do
    it 'responds with a 200' do
      get :index
      expect(response).to have_http_status(:ok)
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
      let!(:payment) {Payment.create!(amount: 100.0, loan_id: loan.id)}

      it 'return return error response' do
        post :create, params: { id: loan.id, amount: 10 }
        expect(JSON.parse(response.body)["status"]).to eq 'error'
        expect(JSON.parse(response.body)["message"]).to eq 'Given amount exceed the outstanding balance of a loan'
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
