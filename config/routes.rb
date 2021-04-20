Rails.application.routes.draw do
  resources :loans, defaults: {format: :json} do
    member do
      get :loan_payments, format: :json
    end
  end
  get "loans/:id/payments/:payment_id" => "loans#loan_payment_info", as: :loan_payment_info
end
