class AddRememberMeTokenToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :remember_me_token, :string
    add_index :users, :remember_me_token, unique: true
  end
end
