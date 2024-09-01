defmodule GreekCoin.Guardian.AdminAuthPipeline do


  use Guardian.Plug.Pipeline, otp_app: :greek_coin,
  module: GreekCoin.Guardian,
  error_handler: GreekCoinWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer", claims: %{"role" => "admin"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
 
  # plug Guardian.Plug.VerifyPermissions, [handler: __MODULE__, default: ~w(revoke_token)] 
   

end
