module Authenticable
  def update_with_password(params)
    current_password = params.delete(:current_password)
    if authenticate(current_password)
      update(params)
    else
      errors.add(:current_password, :invalid)
    end
  end

  def reset_password(params)
    if params[:password].blank?
      errors.add(:password, :blank)
    else
      self.password_reset_token = nil
      update(params)
    end
  end
end
