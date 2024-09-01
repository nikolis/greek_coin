defmodule GreekCoinWeb.WalletView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.WalletView
  alias GreekCoinWeb.CurrencyView
  import Kerosene.JSON



  def render("list.json", %{wallets: wallets, kerosene: kerosene, conn: conn}) do
    %{data: render_many(wallets, WalletView, "wallet.json"),
      pagination: paginate(conn, kerosene)
    }
  end

  def render("index.json", %{wallets: wallets}) do
     %{data: render_many(wallets, WalletView, "wallet.json")}
  end

  def render("show.json", %{wallet: wallet}) do
    %{data: render_one(wallet, WalletView, "wallet.json")}
  end

  def render("wallet_simple.json", %{wallet: wallet}) do
    %{
      public_key: wallet.public_key,
      id: wallet.id,
      active: wallet.active
    }
  end

  def render("wallet.json", %{wallet: wallet}) do
    %{id: wallet.id,
      #private_key: wallet.private_key,
      public_key: wallet.public_key,
      additional_info: wallet.additional_info,
      active: wallet.active,
      currency: render_one(wallet.currency, CurrencyView, "currency.json")
    }
  end

  def render("error.json", %{changeset: changeset}) do
    ret =  Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    IO.inspect ret
    ret
  end 

end
