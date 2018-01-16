module Controllers::Rememberable
  def create_remember_me_cookie
    cookies.encrypted[:remember_me] = {
      value: @user.remember_me_token,
      expires: Date.current + REMEMBER_ME_COOKIE_VALIDITY_DURATION,
      domain: request.domain
    }
  end

  def delete_remember_me_cookie
    cookies.delete(:remember_me, domain: request.domain)
  end
end
