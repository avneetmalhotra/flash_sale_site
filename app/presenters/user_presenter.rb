class UserPresenter < Struct.new(:user)

  def status
    if user.active?
      'Active'
    else
      'Inactive'
    end
  end
end
