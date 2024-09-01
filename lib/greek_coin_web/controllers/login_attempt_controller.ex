defmodule GreekCoinWeb.LoginAttemptController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Accounts
  alias GreekCoin.Accounts.LoginAttempt

  action_fallback GreekCoinWeb.FallbackController

  def index(conn, params) do
    user_auth = Guardian.Plug.current_resource(conn)
    {login_attempts, kerosene} = Accounts.list_login_by_user(user_auth.id, params)
    render(conn, "list.json", login_attempts: login_attempts, kerosene: kerosene, conn: conn)
  end

  def index(conn, _params) do
    login_attempts = Accounts.list_login_attempts()
    render(conn, "index.json", login_attempts: login_attempts)
  end

end
