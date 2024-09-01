defmodule GreekCoin.Authenticator do

  def generate_image_url(secret) do
    NioGoogleAuthenticator.generate_url(secret, "Account 2fa", "Greek-Coin")
  end

  def validate_token(secret, token) do
    NioGoogleAuthenticator.validate_token(secret, token)
  end

end
