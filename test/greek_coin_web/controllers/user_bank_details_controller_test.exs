defmodule GreekCoinWeb.UserBankDetailsControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Funds
  alias GreekCoin.Funds.UserBankDetails

"""

  @create_attrs %{
    acount_no: "some acount_no",
    beneficiary_name: "some beneficiary_name",
    iban: "some iban",
    name: "some name",
    swift_code: "some swift_code"
  }
  @update_attrs %{
    acount_no: "some updated acount_no",
    beneficiary_name: "some updated beneficiary_name",
    iban: "some updated iban",
    name: "some updated name",
    swift_code: "some updated swift_code"
  }
  @invalid_attrs %{acount_no: nil, beneficiary_name: nil, iban: nil, name: nil, swift_code: nil}

  def fixture(:user_bank_details) do
    {:ok, user_bank_details} = Funds.create_user_bank_details(@create_attrs)
    user_bank_details
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user_bank_details", %{conn: conn} do
      conn = get(conn, Routes.user_bank_details_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_bank_details" do
    test "renders user_bank_details when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_bank_details_path(conn, :create), user_bank_details: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_bank_details_path(conn, :show, id))

      assert %{
               "id" => id,
               "acount_no" => "some acount_no",
               "beneficiary_name" => "some beneficiary_name",
               "iban" => "some iban",
               "name" => "some name",
               "swift_code" => "some swift_code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_bank_details_path(conn, :create), user_bank_details: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_bank_details" do
    setup [:create_user_bank_details]

    test "renders user_bank_details when data is valid", %{conn: conn, user_bank_details: %UserBankDetails{id: id} = user_bank_details} do
      conn = put(conn, Routes.user_bank_details_path(conn, :update, user_bank_details), user_bank_details: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_bank_details_path(conn, :show, id))

      assert %{
               "id" => id,
               "acount_no" => "some updated acount_no",
               "beneficiary_name" => "some updated beneficiary_name",
               "iban" => "some updated iban",
               "name" => "some updated name",
               "swift_code" => "some updated swift_code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user_bank_details: user_bank_details} do
      conn = put(conn, Routes.user_bank_details_path(conn, :update, user_bank_details), user_bank_details: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_bank_details" do
    setup [:create_user_bank_details]

    test "deletes chosen user_bank_details", %{conn: conn, user_bank_details: user_bank_details} do
      conn = delete(conn, Routes.user_bank_details_path(conn, :delete, user_bank_details))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_bank_details_path(conn, :show, user_bank_details))
      end
    end
  end

  defp create_user_bank_details(_) do
    user_bank_details = fixture(:user_bank_details)
    {:ok, user_bank_details: user_bank_details}
  end
"""

end
