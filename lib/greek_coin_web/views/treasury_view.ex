defmodule GreekCoinWeb.TreasuryView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.TreasuryView
  alias GreekCoinWeb.CurrencyView
  alias GreekCoinWeb.UserView

  def render("index.json", %{trasuries: trasuries}) do
    %{data: render_many(trasuries, TreasuryView, "treasury.json")}
  end

  def render("show.json", %{treasury: treasury}) do
    %{data: render_one(treasury, TreasuryView, "treasury.json")}
  end

  def render("treasury.json", %{treasury: treasury}) do
    %{id: treasury.id,
      balance: treasury.balance,
      currency: render_one(treasury.currency, CurrencyView, "currency.json"),
      user: render_one(treasury.user, UserView, "user.json")

    }
  end
end
