module TokenGenerator
  def generate_unique_token(field, token_size, token_prefix = '')
    loop do
      token = token_prefix + SecureRandom.hex(token_size)
      break token unless self.class.where(field => token).exists?
    end
  end
end
