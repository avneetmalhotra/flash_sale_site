class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.boolean :admin, default: false
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_token_send_at
      t.string :api_token
      t.string :password_reset_token
      t.datetime :password_reset_token_send_at

      t.timestamps
    end
  end
end
