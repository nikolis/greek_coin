defmodule GreekCoinWeb.FundView do
  use GreekCoinWeb, :view

  alias GreekCoinWeb.FundView
  alias GreekCoinWeb.WithdrawView
  alias GreekCoin.Repo

  def render("user_funds.json", %{user: user}) do
    withdraws = Enum.filter(user.withdrawalls, fn d -> ((d.status == "created") or (d.status == "email_verified")) end)
    withdraws = Repo.preload(withdraws, [:user_wallet, :user_bank_details] )
    IO.inspect withdraws
    %{
      funds: render_many(user.treasuries, FundView, "fund.json"),
      withdraws: render_many(withdraws, WithdrawView, "withdraw.json")
     }
  end
   
  def render("fund.json", treasury) do
    %{balance: treasury.fund.balance,
      currency: treasury.fund.currency.alias_sort
    }
  end

  def render("kyc_failure.json", %{user: user} ) do
    %{
      user_email: user.credential.email,
      problem: "You don't have provided all informations needed from the kyc rules
      please follow instruction to provide all necessery personal information"
    }
  end

  def render("email_verification.json", %{user: user}) do
    %{
      user_email: user.credential.email,
      problem: "Your account is not verified please verify your email, hint: if you missed the email we sent you visit your profiles page to re initiate the process"
    }
  end

end
