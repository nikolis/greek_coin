defmodule GreekCoinWeb.UserWalletView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.UserWalletView

  def render("index.json", %{user_wallets: user_wallets}) do
    %{data: render_many(user_wallets, UserWalletView, "user_wallet.json")}
  end

  def render("show.json", %{user_wallet: user_wallet}) do
    %{data: render_one(user_wallet, UserWalletView, "user_wallet.json")}
  end

  def render("user_wallet.json", %{user_wallet: user_wallet}) do
    %{id: user_wallet.id,
      public_key: user_wallet.bublic_key}
  end
end
