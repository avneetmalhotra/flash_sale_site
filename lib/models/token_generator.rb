module TokenGenerator
  def generate_unique_token(field)
    loop do
      token = SecureRandom.hex(16)
      break token unless User.where(field => token).exists?
    end
  end
end
