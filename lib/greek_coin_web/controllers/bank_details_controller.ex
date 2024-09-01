defmodule GreekCoinWeb.BankDetailsController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.BankDetails
  alias GreekCoin.Repo
  action_fallback GreekCoinWeb.FallbackController

  def client_index(conn, _params) do
    bank_details = Funds.list_active_bank_details()
    render(conn, "index.json", bank_details: bank_details)
  end


  def index(conn, _params) do
    bank_details = Funds.list_bank_details()
    render(conn, "index.json", bank_details: bank_details)
  end

  def get_by_user(conn, _params) do
    user_auth = Guardian.Plug.current_resource(conn)
    bank_details = Funds.list_bank_details()
    render(conn, "index.json", bank_details: bank_details)
  end

  def show(conn, %{"id" => id}) do
    bank_details = Funds.get_bank_details!(id)
    bank_details = Repo.preload(bank_details, :operation_account)
    render(conn, "show.json", bank_details: bank_details)
  end

  def update(conn, %{"id" => id, "bank_details" => bank_details_params}) do
    bank_details = Funds.get_bank_details!(id)
    with {:ok, %BankDetails{} = bank_details} <- Funds.update_bank_details(bank_details, bank_details_params) do
      bank_details = Repo.preload(bank_details, :operation_account)
      render(conn, "bank_details.json", bank_details: bank_details)
    end
  end

end
