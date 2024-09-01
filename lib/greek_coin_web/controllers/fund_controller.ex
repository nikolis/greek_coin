defmodule GreekCoinWeb.FundController do
  use GreekCoinWeb, :controller
   
  action_fallback GreekCoinWeb.FallbackController

  alias GreekCoin.Accounts
  alias GreekCoin.Repo

  def get_user_balance(conn, _) do
    user_auth = Guardian.Plug.current_resource(conn)

    user = Accounts.get_user!(user_auth.id)
    user = Repo.preload(user, [{:treasuries, :currency}, {:withdrawalls, :currency}])
    render(conn, "user_funds.json", user: user, )
  end

  def exchange(conn, _something) do
    user_auth = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_auth.id)

    case user_auth.status do
      "kyc_complient" ->
        user = Repo.preload(user, [treasuries: :currency])
        render(conn, "user_funds.json", user: user)

      "email_verified" ->
        render(conn, "kyc_failure.json", user: user)

       _ ->
        render(conn, "email_verification.json", user: user)
    end
     
 end


end
