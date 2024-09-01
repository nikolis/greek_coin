defmodule GreekCoinWeb.KrakenController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Currency

  action_fallback GreekCoinWeb.FallbackController

  def get_asset_pairs(conn, _params) do
    currencies = Funds.list_currencies()
    conn
    |> render("list.json", %{currencies: currencies})
  end


  def deposit_monetary_currency(conn, _params) do
    currencies = Funds.list_monetary_currency()
    conn
    |> render("list.json", %{currencies: currencies})
  end


  def get_active_currencies(conn, %{"nature" => nature }) do
    currencies = 
      case nature do
        "all" ->
          Funds.list_all_active_currencies()

        "crupto" ->
          Funds.list_active_currencies()

        "traditional"->
          Funds.list_monetary_currency()
        _ ->
          Funds.list_all_active_currencies()
      end
    conn
    |> render("list.json", %{currencies: currencies})

  end


  def get_kraken_pairs(conn, _params) do
    currencies = Funds.list_active_currencies
    conn
    |> render("list.json", %{currencies: currencies})
  end


  def get_pairs(conn, _params) do
    {:ok, %HTTPoison.Response{body: body}} = 
      asset_pair_query_url()
      |> HTTPoison.post("",[{"Content-Type", "application\json"}])
    dec_body = 
      body
      |> Poison.decode!
    %{"error"=> _errors, "result"=> result} = dec_body
    list = Map.values(result)
    record_list = Enum.map(list, fn re -> %{quote: re["quote"], base: re["base"], altname: re["altname"]} end)
    json(conn, %{"data" => record_list})
  end

  def get_kraken_pairs_raw(conn, _params) do 
    {:ok, %HTTPoison.Response{body: body}} = 
      asset_pair_query_url()
      |> HTTPoison.post("",[{"Content-Type", "application\json"}])
    dec_body = 
      body
      |> Poison.decode!

    json(conn, dec_body)
  end 

  def asset_pair_query_url() do
    URI.to_string(%URI{
      scheme: "https",
      host: "api.kraken.com",  
      path: "/0/public/AssetPairs"
      })
  end

end
