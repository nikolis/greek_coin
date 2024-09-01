defmodule GreekCoinWeb.DepositView do

  use GreekCoinWeb, :view

  alias GreekCoinWeb.BankDetailsView
  alias GreekCoinWeb.WalletView 
  alias GreekCoinWeb.DepositView
  import Kerosene.JSON
  alias GreekCoinWeb.CurrencyView
  alias  GreekCoinWeb.ChangesetView


  def render("list.json", %{deposits: deposits, kerosene: kerosene, conn: conn}) do
    %{data: render_many(deposits, DepositView, "deposit.json"),
      pagination: paginate(conn, kerosene)
    }
  end

  def render("list_simple.json", %{deposits: deposits}) do
    %{data: render_many(deposits, DepositView, "deposit.json")
    }
  end 

  def render("show.json", %{deposit: deposit}) do
    render_one(deposit, DepositView, "deposit.json")
  end

  def render("deposit.json", %{deposit: deposit}) do
    %{
      id: deposit.id,
      ammount: deposit.ammount,
      status: deposit.status,
      update_at: deposit.updated_at,
      comment: deposit.comment,
      currency: render_one(deposit.currency, CurrencyView,"currency.json"),
      alias: deposit.alias,
      wallet: render_one(deposit.wallet, WalletView, "wallet_simple.json"),
      bank_details: render_one(deposit.bank_details, BankDetailsView, "bank_details_simple.json")
    }
  end

  def render("error.json", %{changeset: changeset}) do
    render_one(changeset, GreekCoinWeb.ChangesetView, "error.json")
  end


end
