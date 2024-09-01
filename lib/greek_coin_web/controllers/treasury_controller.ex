defmodule GreekCoinWeb.TreasuryController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Treasury

  action_fallback GreekCoinWeb.FallbackController

  def index(conn, _params) do
    user_res = Guardian.Plug.current_resource(conn)
    trasuries = Funds.list_treasuries_user_id(user_res.id)
    render(conn, "index.json", trasuries: trasuries)
  end


  def show(conn, %{"id" => id}) do
    treasury = Funds.get_treasury!(id)
    render(conn, "show.json", treasury: treasury)
  end

end
