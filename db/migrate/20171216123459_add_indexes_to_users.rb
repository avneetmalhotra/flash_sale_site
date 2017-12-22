class AddIndexesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :api_token, unique: true

    add_index :users, :confirmation_token, unique: true

    add_index :users, :password_reset_token, unique: true

    add_index :users, :email, unique: true
  end
end
