defmodule GreekCoinWeb.WithdrawView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.WithdrawView
  alias GreekCoinWeb.UserWalletView
  alias GreekCoinWeb.UserView
  alias GreekCoinWeb.CountryView
  alias GreekCoinWeb.UserBankDetailsView
  alias GreekCoinWeb.CurrencyView
  import Kerosene.JSON

  def render("list.json", %{withdraw: withdraw, kerosene: kerosene, conn: conn}) do
    %{data: render_many(withdraw, WithdrawView, "withdraw.json"),
      pagination: paginate(conn, kerosene)
    }
  end

  def render("index.json", %{withdrawals: withdrawals}) do
    %{data: render_many(withdrawals, WithdrawView, "withdraw.json")}
  end

  def render("show.json", %{withdraw: withdraw}) do
    render_one(withdraw, WithdrawView, "withdraw.json")
  end

  def render("show2fa.json", %{withdraw: withdraw}) do
    %{ withdraw: render_one(withdraw, WithdrawView, "withdraw.json"),
      token: nil
     }
  end

  def render("withdraw.json", %{withdraw: withdraw}) do
    %{id: withdraw.id,
      status: withdraw.status,
      update_at: withdraw.updated_at,
      ammount: withdraw.ammount,
      comment: withdraw.comment,
      currency: render_one(withdraw.currency, CurrencyView, "currency.json"),
      user_wallet: render_one(withdraw.user_wallet, UserWalletView, "user_wallet.json"),
      user_bank_details: render_one(withdraw.user_bank_details, UserBankDetailsView, "user_bank_details.json")
    }
  end
end
