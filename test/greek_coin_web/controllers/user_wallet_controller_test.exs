defmodule GreekCoinWeb.UserWalletControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Funds
  alias GreekCoin.Funds.UserWallet

"""
  @create_attrs %{
    bublic_key: "some bublic_key"
  }
  @update_attrs %{
    bublic_key: "some updated bublic_key"
  }
  @invalid_attrs %{bublic_key: nil}

  def fixture(:user_wallet) do
    {:ok, user_wallet} = Funds.create_user_wallet(@create_attrs)
    user_wallet
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user_wallets", %{conn: conn} do
      conn = get(conn, Routes.user_wallet_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_wallet" do
    test "renders user_wallet when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_wallet_path(conn, :create), user_wallet: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_wallet_path(conn, :show, id))

      assert %{
               "id" => id,
               "bublic_key" => "some bublic_key"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_wallet_path(conn, :create), user_wallet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_wallet" do
    setup [:create_user_wallet]

    test "renders user_wallet when data is valid", %{conn: conn, user_wallet: %UserWallet{id: id} = user_wallet} do
      conn = put(conn, Routes.user_wallet_path(conn, :update, user_wallet), user_wallet: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_wallet_path(conn, :show, id))

      assert %{
               "id" => id,
               "bublic_key" => "some updated bublic_key"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user_wallet: user_wallet} do
      conn = put(conn, Routes.user_wallet_path(conn, :update, user_wallet), user_wallet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_wallet" do
    setup [:create_user_wallet]

    test "deletes chosen user_wallet", %{conn: conn, user_wallet: user_wallet} do
      conn = delete(conn, Routes.user_wallet_path(conn, :delete, user_wallet))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_wallet_path(conn, :show, user_wallet))
      end
    end
  end

  defp create_user_wallet(_) do
    user_wallet = fixture(:user_wallet)
    {:ok, user_wallet: user_wallet}
  end
"""
end
