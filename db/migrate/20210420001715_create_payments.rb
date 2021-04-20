class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.decimal :amount, precision: 8, scale: 2
      t.integer :loan_id
      t.timestamps null: false

      add_foreign_key :payments, :loans, on_delete: :cascade
    end
  end
end
