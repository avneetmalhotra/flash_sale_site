class UserPresenter < Struct.new(:user)

  def status
    if user.active?
      'Active'
    else
      'Inactive'
    end
  end

  def confirmation_status
    if user.confirmed_at.present?
      user.confirmed_at
    else
      'Not Confirmed'
    end
  end
end
