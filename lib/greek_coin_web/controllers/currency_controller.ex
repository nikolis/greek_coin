defmodule GreekCoinWeb.CurrencyController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Currency

  action_fallback GreekCoinWeb.FallbackController

  def index(conn, _params) do
    currencies = Funds.list_currencies()
    render(conn, "index.json", currencies: currencies)
  end

  def show(conn, %{"id" => id}) do
    currency = Funds.get_currency!(id)
    render(conn, "show.json", currency: currency)
  end

end
