defmodule GreekCoinWeb.UserBankDetailsView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.UserBankDetailsView

  def render("index.json", %{user_bank_details: user_bank_details}) do
    %{data: render_many(user_bank_details, UserBankDetailsView, "user_bank_details.json")}
  end

  def render("show.json", %{user_bank_details: user_bank_details}) do
    %{data: render_one(user_bank_details, UserBankDetailsView, "user_bank_details.json")}
  end

  def render("user_bank_details.json", %{user_bank_details: user_bank_details}) do
    %{id: user_bank_details.id,
      beneficiary_name: user_bank_details.beneficiary_name,
      iban: user_bank_details.iban,
      swift_code: user_bank_details.swift_code,
      recipient_address: user_bank_details.recipient_address,
      bank_address: "",
      name: user_bank_details.name}
  end
end
