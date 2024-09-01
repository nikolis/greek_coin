defmodule GreekCoinWeb.ActionController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Action

  action_fallback GreekCoinWeb.FallbackController

  def index(conn, _params) do
    actions = Funds.list_actions()
    render(conn, "index.json", actions: actions)
  end

  def show(conn, %{"id" => id}) do
    action = Funds.get_action!(id)
    render(conn, "show.json", action: action)
  end
end
