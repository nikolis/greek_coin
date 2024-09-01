defmodule GreekCoinWeb.UserWalletController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.UserWallet

  action_fallback GreekCoinWeb.FallbackController

  def index(conn, _params) do
    user_wallets = Funds.list_user_wallets()
    render(conn, "index.json", user_wallets: user_wallets)
  end

  def create(conn, %{"user_wallet" => user_wallet_params}) do
    with {:ok, %UserWallet{} = user_wallet} <- Funds.create_user_wallet(user_wallet_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user_wallet: user_wallet)
    end
  end

  def show(conn, %{"id" => id}) do
    user_wallet = Funds.get_user_wallet!(id)
    render(conn, "show.json", user_wallet: user_wallet)
  end

  def update(conn, %{"id" => id, "user_wallet" => user_wallet_params}) do
    user_wallet = Funds.get_user_wallet!(id)

    with {:ok, %UserWallet{} = user_wallet} <- Funds.update_user_wallet(user_wallet, user_wallet_params) do
      render(conn, "show.json", user_wallet: user_wallet)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_wallet = Funds.get_user_wallet!(id)

    with {:ok, %UserWallet{}} <- Funds.delete_user_wallet(user_wallet) do
      send_resp(conn, :no_content, "")
    end
  end
end
