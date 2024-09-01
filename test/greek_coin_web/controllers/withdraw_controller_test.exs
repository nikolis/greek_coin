defmodule GreekCoinWeb.WithdrawControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Withdraw
  alias GreekCoin.Accounts
  alias GreekCoin.Accounting.OperationAccount
  alias GreekCoin.Accounting

  @create_attrs %{
    ammount: 120.5
  }
  @update_attrs %{
    ammount: 456.7
  }
  @invalid_attrs %{ammount: nil}

  #def fixture(:withdraw) do
  # {:ok, withdraw} = Funds.create_withdraw(@create_attrs)
  # withdraw
  #end

  #  setup %{conn: conn} do
  #  {:ok, conn: put_req_header(conn, "accept", "application/json")}
  #end

  describe "index" do
    test "lists all withdrawals", %{conn: conn} do
      {:ok, _user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin"})
      conn2 = post(build_conn(), Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = get(conn, Routes.withdraw_path(conn, :index, "all",  "all", "all"))
      assert json_response(conn, 200)["data"] == []

    end
  end

  describe "create and proccess withdraw" do

    test "create and proccess withdraw should decrease user and operation account balance when account does not have enough funds an error is rendered and the completion is declined" do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin", decimals: 6, withdraw_fee: 3.5})
      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})
      {:ok, treas} = Funds.create_treasury(%{user_id: user.id, currency_id: eur.id, balance: 5000})

      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, status: "created", user_id: user.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.withdraw_path(conn, :create), withdraw: attrs )
      withdraw = json_response(conn, 201)
      withdraw2 = struct(Withdraw, %{id: withdraw["withdraw"]["id"]})
      IO.inspect(GreekCoin.Funds.mark_withdrawall_as_email_verified(withdraw2))
      conn = get(conn, Routes.withdraw_path(conn, :show, withdraw["withdraw"]["id"]))

      assert %{
               "id" => id,
               "ammount" => 120.5,
               "status" => "email_verified"
              } = json_response(conn, 200)

    end

    test "create and proccess withdraw should not be possible if withdraw failed validation" do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin", decimals: 6, alias_sort: "BTC", withdraw_fee: 3.0})
      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})
      {:ok, treas} = Funds.create_treasury(%{user_id: user.id, currency_id: eur.id, balance: 5000})
      {:ok, inventory} = Accounting.create_inventory(%{operation_account_id: operation_acccount.id, balance: 5000, currency_id: eur.id})


      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, status: "created", user_id: user.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.withdraw_path(conn, :create), withdraw: attrs )
      withdraw = json_response(conn, 201)
      conn = get(conn, Routes.withdraw_path(conn, :show, withdraw["withdraw"]["id"]))
      withdraw = json_response(conn, 200)
      assert %{
               "id" => id,
               "ammount" => 120.5
              } = withdraw

    end

  end

  describe "create withdraw" do
    test "renders withdraw when data is valid", %{conn: conn} do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin", decimals: 6, withdraw_fee: 3.5})
      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})
      {:ok, treas} = Funds.create_treasury(%{user_id: user.id, currency_id: eur.id, balance: 5000})

      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, status: "created", user_id: user.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.withdraw_path(conn, :create), withdraw: attrs )
      withdraw = json_response(conn, 201)
      conn = get(conn, Routes.withdraw_path(conn, :show, withdraw["withdraw"]["id"]))

      assert %{
               "id" => id,
               "ammount" => 120.5
      } = json_response(conn, 200)

    end

    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal231@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal231@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2) 
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 


      conn = post(conn, Routes.withdraw_path(conn, :create), withdraw: @invalid_attrs)
      assert json_response(conn, 403)== %{"error" => "Currency not recognized"}
    end
  end
"""
  describe "update withdraw" do
    setup [:create_withdraw]

    test "renders withdraw when data is valid", %{conn: conn, withdraw: %Withdraw{id: id} = withdraw} do
      conn = put(conn, Routes.withdraw_path(conn, :update, withdraw), withdraw: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.withdraw_path(conn, :show, id))

      assert %{
               "id" => id,
               "ammount" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, withdraw: withdraw} do
      conn = put(conn, Routes.withdraw_path(conn, :update, withdraw), withdraw: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete withdraw" do
    setup [:create_withdraw]

    test "deletes chosen withdraw", %{conn: conn, withdraw: withdraw} do
      conn = delete(conn, Routes.withdraw_path(conn, :delete, withdraw))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.withdraw_path(conn, :show, withdraw))
      end
    end
  end

  defp create_withdraw(_) do
    withdraw = fixture(:withdraw)
    {:ok, withdraw: withdraw}
  end
"""
end
