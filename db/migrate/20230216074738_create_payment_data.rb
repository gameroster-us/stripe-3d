class CreatePaymentData < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_data do |t|
      t.string :payment_token
      t.float :amount
      t.boolean :status, default: false
      t.timestamps
    end
  end
end
