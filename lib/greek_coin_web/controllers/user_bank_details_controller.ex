defmodule GreekCoinWeb.UserBankDetailsController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.UserBankDetails

  action_fallback GreekCoinWeb.FallbackController

  def index(conn, _params) do
    user_bank_details = Funds.list_user_bank_details()
    render(conn, "index.json", user_bank_details: user_bank_details)
  end

  def create(conn, %{"user_bank_details" => user_bank_details_params}) do
    with {:ok, %UserBankDetails{} = user_bank_details} <- Funds.create_user_bank_details(user_bank_details_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user_bank_details: user_bank_details)
    end
  end

  def show(conn, %{"id" => id}) do
    user_bank_details = Funds.get_user_bank_details!(id)
    render(conn, "show.json", user_bank_details: user_bank_details)
  end

  def update(conn, %{"id" => id, "user_bank_details" => user_bank_details_params}) do
    user_bank_details = Funds.get_user_bank_details!(id)

    with {:ok, %UserBankDetails{} = user_bank_details} <- Funds.update_user_bank_details(user_bank_details, user_bank_details_params) do
      render(conn, "show.json", user_bank_details: user_bank_details)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_bank_details = Funds.get_user_bank_details!(id)

    with {:ok, %UserBankDetails{}} <- Funds.delete_user_bank_details(user_bank_details) do
      send_resp(conn, :no_content, "")
    end
  end
end
