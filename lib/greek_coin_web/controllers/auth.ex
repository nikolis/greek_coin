defmodule GreekCoinWeb.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && GreekCoin.Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end
 
  def login(conn, user) do

    conn = 
      conn
      |> assign(:current_user, user)
      |> put_session(:user_id, user.id)
      |> configure_session(renew: true)
    conn
  end

end
