# Payments Exercise

Add in the ability to create payments for a given loan using a JSON API call. You should store the payment date and amount. Expose the outstanding balance for a given loan in the JSON vended for `LoansController#show` and `LoansController#index`. The outstanding balance should be calculated as the `funded_amount` minus all of the payment amounts.

A payment should not be able to be created that exceeds the outstanding balance of a loan. You should return validation errors if a payment can not be created. Expose endpoints for seeing all payments for a given loan as well as seeing an individual payment.

# API End Points

_LoansController#index_ - This end point will expose information about all the loans and their respective payments

**Sample Response**
```json
{ "loan_id": [{ "payment_id": "payment.id", "balance_left": "balance_left", "paid_amount": "payment.amount", "payment_made": "payment.created_at" }] }
```

_LoansController#loan_payments_ - This end point will expose information about payments of a particular loan

**Sample Response**
```json
{"loan_id": [{"payment_id": "payment.id", "balance_left": "20.0", "paid_amount": "80.0", "payment_made": "created_time_stamp"}] }
```

_LoansController#loan_payment_info_ - This end point will expose information about a particular payment

**Sample Response**
```json
{"loan_id": 1,"payment_amount": "80.0","payment_made": "created_time_stamp"}
```

_LoansController#show_ - This end point will expose information about a loan and the outstanding balance

**Sample Response**
```json
{"loan_funded": "100.0","outstanding_balance":"20.0"}
```

**Environment Setup**
```
rbenv install 2.6.6
gem install bundler -v 2.2.16
gem install rails -v 5.2.4.4
bundle exec rake db:migrate
```

**Start Rails Server**
```
rails s
```
