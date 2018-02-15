require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'invalid without name' do
    user = User.new
    user.valid?
    assert_includes(user.errors[:name], "can't be blank")
  end

  test 'invalid without email' do
    user = User.new
    user.valid?
    assert_includes(user.errors[:email], "can't be blank")
  end

  test 'invalid without password' do
    user = User.new
    user.valid?
    assert_includes(user.errors[:password], "can't be blank")
  end

  test 'invalid with duplicate email' do
    user = User.new email: 'user1@mail.com'
    user.valid?
    assert_includes(user.errors[:email], 'has already been taken')
  end

  test 'invalid with wrong email format' do
    user = User.new email: 'ada'
    user.valid?
    assert_includes(user.errors[:email], "is invalid")
  end

  test 'invalid without password when password confirmation presenet on update' do
    user = User.first
    user.password_confirmation = 'newpassword'
    user.valid?
    assert_includes(user.errors[:password], "can't be blank")
  end

  test 'invalid with password length less than 6' do
    user = User.new password: 'six'
    user.valid?
    assert_includes(user.errors[:password], 'is too short (minimum is 6 characters)')
  end

  test 'password reset instructions are sent' do
    assert_difference 'Delayed::Job.count' do
      User.first.send_password_reset_instructions
    end
  end

  test 'confirmation instructions are sent' do
    assert_difference 'Delayed::Job.count' do
      user = User.new(name: 'new', email: 'new@mail.com', password: 'password', password_confirmation: 'password')
      assert user.save
    end
  end

  test 'update with password succeeds' do
    user = User.first
    assert user.update_with_password(name: 'new_name', current_password: 'password', password: 'newpass', password_confirmation: 'newpass')
  end

  test 'update with password fails' do
    user = User.third
    # when password != password_confirmation
    user.update_with_password(name: 'new_name',current_password: 'password', password: 'onepass', password_confirmation: 'two_pass')
    assert_includes(user.errors[:password_confirmation], "doesn't match Password")
    
    # when current_password is wrong
    user.update_with_password(name: 'new_name',current_password: 'wrong_password', password: 'onepass', password_confirmation: 'two_pass')
    assert_includes(user.errors[:current_password], "is invalid")
  end

  test 'reset password succeeds' do
    user = User.third
    assert user.reset_password(password: 'newpass', password_confirmation: 'newpass')
  end

  test 'reset password fails' do
    user = User.third
    user.reset_password(password: '', password_confirmation: 'newpass')
    assert_includes(user.errors[:password], "can't be blank")
  end

  test 'whether confirmation token has expired' do
    user = User.first
    assert user.confirmation_token_expired?

    ##
    user.update_columns(confirmation_token: nil)
    assert user.confirmation_token_expired?

    ##
    user.reload.update_columns(confirmation_token_sent_at: nil)
    assert user.confirmation_token_expired?    
  end

  test 'whether password reset token has expired' do
    user = User.second
    assert user.password_reset_token_expired?

    ##
    user = User.first
    user.update_columns(password_reset_token: nil)
    assert user.password_reset_token_expired?

    ##
    user.reload.update_columns(password_reset_token_sent_at: nil)
    assert user.password_reset_token_expired?    
  end

  test 'whether returns correct recently used address id' do
    user = User.first
    recently_used_address_id = user.orders.complete.last.address_id
    assert_equal(user.recently_used_address_id ,recently_used_address_id)
  end

  test 'whether returns nil as recently used address id' do
    user = User.second
    assert_nil(user.recently_used_address_id)
  end

  test 'confirm user' do
    assert User.second.confirm
  end

  test 'presentable object returned' do
    user = User.first
    presenter_object = UserPresenter.new(user)
    assert_equal(presenter_object, user.presenter)
  end

end
