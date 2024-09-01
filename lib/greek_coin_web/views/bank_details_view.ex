defmodule GreekCoinWeb.BankDetailsView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.BankDetailsView
  alias GreekCoinWeb.CountryView
  alias  GreekCoinWeb.ChangesetView
  alias GreekCoinWeb.OperationAccountView 

  def render("index.json", %{bank_details: bank_details}) do
    %{data: render_many(bank_details, BankDetailsView, "bank_details.json")}
  end

  def render("show.json", %{bank_details: bank_details}) do
    %{data: render_one(bank_details, BankDetailsView, "bank_details.json")}
  end

  def render("bank_details_simple.json", %{bank_details: bank_details}) do
    %{id: bank_details.id,
      name: bank_details.name,
      swift_code: bank_details.swift_code,
      recipient_address: bank_details.recipient_address,
      bank_address: bank_details.bank_address,
      iban: bank_details.iban,
      active: bank_details.active,
      beneficiary_name: bank_details.beneficiary_name}
  end

  def render("bank_details.json", %{bank_details: bank_details}) do
    %{country: render_one(bank_details.country, CountryView, "country.json"),
      id: bank_details.id,
      name: bank_details.name,
      swift_code: bank_details.swift_code,
      bank_address: bank_details.bank_address,
      recipient_address: bank_details.recipient_address,
      iban: bank_details.iban,
      active: bank_details.active,
      operation_account: render_one(bank_details.operation_account, OperationAccountView, "operation_account_simple.json"),
      beneficiary_name: bank_details.beneficiary_name}

  end

  def render("error.json", %{changeset: changeset}) do
    ret =  Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    ret
  end 

end
