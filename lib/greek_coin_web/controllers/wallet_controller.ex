defmodule GreekCoinWeb.WalletController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Wallet
  alias GreekCoin.Repo
  action_fallback GreekCoinWeb.FallbackController
  import Ecto.Query
  alias GreekCoin.Repo


  def index(conn, params) do
    mode = Map.get(params, "mode")
    currency_id = Map.get(params, "currency_id")
    query = 
      case mode do 
        "all" ->
           if( "nil" == currency_id) do
             from wallet in Wallet
           else
             from wallet in Wallet,
             where: wallet.currency_id == ^currency_id
           end
        "free" ->
          if( "nil" == currency_id) do
             from(wallet in Wallet,
               where: is_nil(wallet.user_id))
          else 
             from(wallet in Wallet,
               where: is_nil(wallet.user_id) and wallet.currency_id == ^currency_id)
          end
      end
    {wallets, kerosene} = Repo.paginate(query, params)
    wallets = Repo.preload(wallets, [:currency, :user])
    render(conn, "list.json", wallets: wallets, kerosene: kerosene)
  end

  def list_user_wallet(conn, params) do 
    user_res = Guardian.Plug.current_resource(conn)
    wallets = Funds.list_wallets_per_user(user_res.id)
    render(conn, "index.json", wallets: wallets)
  end

  def show(conn, %{"id" => id}) do
    wallet = Funds.get_wallet!(id)
    render(conn, "show.json", wallet: wallet)
  end

end
