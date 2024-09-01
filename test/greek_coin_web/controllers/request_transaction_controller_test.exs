defmodule GreekCoinWeb.RequestTransactionControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Funds
  alias GreekCoin.Funds.RequestTransaction
  alias GreekCoin.Accounts
  alias GreekCoin.Repo
  alias GreekCoin.Accounts.User
  alias GreekCoin.Accounting

  @create_attrs %{
    exchange_rate: 120.5,
    src_amount: 120.5,
    status: "some status"
  }
  @update_attrs %{
    exchange_rate: 456.7,
    src_amount: 456.7,
    status: "some updated status"
  }
  @invalid_attrs %{exchange_rate: nil, src_amount: nil, status: nil}

  def fixture(:request_transaction) do
    {:ok, request_transaction} = Funds.create_request_transaction(@create_attrs)
    request_transaction
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create request_transaction" do

    test "create and execute a complete transaction for Buying", %{conn: conn} do
      startBalance = 20000
      endCost = 10000

      {:ok, user} = Accounts.create_user(%{user_name: "so usernasdfame", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified", role: "admin", clearance_level: 1})
      {:ok, action} = Funds.create_action(%{title: "Buy"})

      {:ok, user} = Accounts.admin_user_update(user, %{status: "kyc_complient"})

      {:ok, currency1} = Funds.create_currency(%{"title" => "XXBT", "active" => true , "fee" => "3", "active_deposit" => false, "decimals" => 5 })
      {:ok, currency2} = Funds.create_currency(%{"title" => "ZEUR", "active" => true , "fee" => "3", "active_deposit" => false, "decimals" => 2})

      {:ok, treasury} = Funds.create_treasury(%{user_id: user.id, currency_id: currency1.id, balance: startBalance})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 
      valid_attrs = Map.merge(@create_attrs, %{src_currency_id: currency1.id, tgt_currency_id: currency2.id, action_id: action.id, pair: "XXBTZEUR", fee: 3, src_amount: 1})


      conn = post(conn, Routes.request_transaction_path(conn, :sell_create), request_transaction: valid_attrs)
      result = json_response(conn, 202)
      transaction = result["transaction"]
 
      assert %{"id" => id} = json_response(conn, 202)["transaction"]
      conn = post(conn, Routes.request_transaction_path(conn, :verify_request), token: result["token"])
      result2 = json_response(conn, 201)

    end

    test "create and execute a complete transaction for Selling", %{conn: conn} do
      startBalance = 2
      endCost = 9000

      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified", role: "admin", clearance_level: 1})
      {:ok, action} = Funds.create_action(%{title: "Sell"})

      {:ok, user} = Accounts.admin_user_update(user, %{status: "kyc_complient"})

      {:ok, currency1} = Funds.create_currency(%{"title" => "XXBT", "active" => true , "fee" => "3", "active_deposit" => false , "decimals" => 6})
      {:ok, currency2} = Funds.create_currency(%{"title" => "ZEUR", "active" => true , "fee" => "3", "active_deposit" => false , "decimals" => 2})

      {:ok, treasury} = Funds.create_treasury(%{user_id: user.id, currency_id: currency1.id, balance: startBalance})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 
      valid_attrs = Map.merge(@create_attrs, %{src_currency_id: currency2.id, tgt_currency_id: currency1.id, action_id: action.id, pair: "XXBTZEUR", fee: 3, src_amount: 1})


      conn = post(conn, Routes.request_transaction_path(conn, :sell_create), request_transaction: valid_attrs)
      result = json_response(conn, 202)
      transaction = result["transaction"]
 
      assert %{"id" => id} = json_response(conn, 202)["transaction"]
      conn = post(conn, Routes.request_transaction_path(conn, :verify_request), token: result["token"])
      result2 = json_response(conn, 201)

    end


"""
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.request_transaction_path(conn, :create), request_transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
"""
  end
"""
  describe "update request_transaction" do
    setup [:create_request_transaction]

    test "renders request_transaction when data is valid", %{conn: conn, request_transaction: %RequestTransaction{id: id} = request_transaction} do
      conn = put(conn, Routes.request_transaction_path(conn, :update, request_transaction), request_transaction: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.request_transaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "exchange_rate" => 456.7,
               "src_amount" => 456.7,
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, request_transaction: request_transaction} do
      conn = put(conn, Routes.request_transaction_path(conn, :update, request_transaction), request_transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete request_transaction" do
    setup [:create_request_transaction]

    test "deletes chosen request_transaction", %{conn: conn, request_transaction: request_transaction} do
      conn = delete(conn, Routes.request_transaction_path(conn, :delete, request_transaction))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.request_transaction_path(conn, :show, request_transaction))
      end
    end
  end
"""
  defp create_request_transaction(_) do
    request_transaction = fixture(:request_transaction)
    {:ok, request_transaction: request_transaction}
  end
end
