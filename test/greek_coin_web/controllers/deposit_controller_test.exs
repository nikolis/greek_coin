defmodule GreekCoinWeb.DepositControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Funds
  alias GreekCoin.Accounting.OperationAccount
  alias GreekCoin.Accounts

  @create_attrs %{ammount: 120.5, status: "some status"}
  #@update_attrs %{ammount: 456.7, status: "some updated status"}
  #@invalid_attrs %{ammount: nil, status: nil}

  def fixture(:deposit) do
    {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur", decimals: 2})
    {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
    {:ok, wallet} = GreekCoin.Funds.create_wallet(%{currency_id: eur.id, operation_account_id: operation_acccount.id, public_key: "somekewywyueafdsf"})
    {:ok, user} = Accounts.create_user(%{user_name: "so usernam2332e", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified", role: "admin", clearance_level: 1})
    {:ok, wallet} = GreekCoin.Funds.create_bank_details(%{currency_id: eur.id, operation_account_id: operation_acccount.id, beneficiary_name: "somekewywyueafdsf", iban: "ADFAF32F23FAFFA", acount_no: "5343242", swift_code: "some swift", name: "asdf"})

    attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, bank_details_id: wallet.id, status: "created", user_id: user.id})

    {:ok, deposit} = Funds.create_deposit_monetary(attrs, "")
    deposit
  end

  describe "index" do
    test "lists all deposits", %{conn: conn} do
      {:ok, _user} = Accounts.create_user(%{user_name: "so username2", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin"})
      conn2 = post(build_conn(), Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = get(conn, Routes.deposit_path(conn, :index), %{mode: "all", date: "all", toDate: "all"})
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "new deposit" do
    test "create deposit invalid data" do

      {:ok, _user} = Accounts.create_user(%{user_name: "so username2", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})
      conn2 = post(build_conn(), Routes.auth_path(build_conn(), :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn =
        conn 
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.deposit_path(conn, :create), deposit: @create_attrs )
      assert json_response(conn, 403)["error"] == "A currency is needed"
    end
  end

  describe "create deposit" do
    test "renderes apropriate error when currency chosen does not have an available wallet", %{conn: conn} do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin", decimals: 6, active_deposit: true})
      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})

      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, status: "created", user_id: user.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs )

      assert json_response(conn, 403) == %{"error" => "There is no available wallet"} 
    end


    test "renderes apropriate error when currency chosen us eur and there is no bank available", %{conn: conn} do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EURO", alias: "EUR", decimals: 2, active_deposit: true})
      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
      {:ok, wallet} = GreekCoin.Funds.create_wallet(%{currency_id: eur.id, operation_account_id: operation_acccount.id, public_key: "somekewywyueafdsf"})
      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})

      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, status: "created", user_id: user.id, wallet_id: wallet.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})
      conn = recycle(conn2)
      body = json_response(conn2, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs )

      assert json_response(conn, 400) == %{"errors" => %{"bank_details_id" => ["can't be blank"]}} 
    end



    test "redirects to show when data is valid", %{conn: conn} do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur", decimals: 2, active_deposit: true})
      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
      {:ok, wallet} = GreekCoin.Funds.create_bank_details(%{currency_id: eur.id, operation_account_id: operation_acccount.id, beneficiary_name: "somekewywyueafdsf", iban: "ADFAF32F23FAFFA", acount_no: "5343242", name: "asdfas", swift_code: "asdfsadf"})
      {:ok, user} = Accounts.create_user(%{user_name: "so use2323rname", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})

      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, bank_details_id: wallet.id, status: "created", user_id: user.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs )

      assert json_response(conn, 201)["ammount"] ==  120.5
    end

    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "EURO", decimals: 2, active_deposit: true})
      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
      {:ok, user} = Accounts.create_user(%{user_name: "so user2323name", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})

      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, status: "created", user_id: user.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      conn = recycle(conn2)
      body = json_response(conn2, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs )

      assert json_response(conn, 400)["errors"] == %{"bank_details_id" => ["can't be blank"]}

    end
  end

  defp create_deposit(_) do
    deposit = fixture(:deposit)
    {:ok, deposit: deposit}
  end

  describe "delete deposit" do
    setup [:create_deposit]

    test "deletes chosen deposit", %{conn: conn, deposit: deposit} do
      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = delete(conn, Routes.deposit_path(conn, :delete, deposit))
      assert json_response(conn, 200)["id"] == deposit.id
      conn = get(conn, Routes.deposit_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end


  describe "create and proccess deposit" do

    test "create and mark paid a valid deposit should transfer user the money as well as apropriate operation accounts" do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur", decimals: 2, alias_sort: "EUR", active_deposit: true})
      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})
      {:ok, wallet} = GreekCoin.Funds.create_bank_details(%{currency_id: eur.id, operation_account_id: operation_acccount.id, beneficiary_name: "somekewywyueafdsf", iban: "ADFAF32F23FAFFA", acount_no: "5343242", name: "asdfsdfa", swift_code: "asdfsad"})
      {:ok, user} = Accounts.create_user(%{user_name: "so usern23ame", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})

      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, bank_details_id: wallet.id, status: "created", user_id: user.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs )
      deposit = json_response(conn, 201)
      assert deposit["ammount"] ==  120.5
    end

  end

"""
  describe "edit deposit" do
    setup [:create_deposit]


    test "renders form for editing chosen deposit", %{conn: conn, deposit: deposit} do
      {:ok, user} = Accounts.create_user(%{user_name: "so username2", credential: %{email: "nikolisgal2@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified", role: "admin"})
      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = get(conn, Routes.deposit_path(conn, :edit, deposit))
      assert html_response(conn, 200) =~ "Edit Deposit"
    end
  end
"""
"""
  describe "update deposit" do
    setup [:create_deposit]

    test "redirects when data is valid", %{conn: conn, deposit: deposit} do
    {:ok, user} = Accounts.create_user(%{user_name: "so username2", credential: %{email: "nikolisgal2@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified", role: "admin"})
      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = put(conn, Routes.deposit_path(conn, :update, deposit), deposit: @update_attrs)
      assert  = json_response(conn, 201)

      conn = get(conn, Routes.deposit_path(conn, :show, deposit))
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, deposit: deposit} do
      conn = put(conn, Routes.deposit_path(conn, :update, deposit), deposit: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Deposit"
    end
  end

  describe "delete deposit" do
    setup [:create_deposit]

    test "deletes chosen deposit", %{conn: conn, deposit: deposit} do
      conn = delete(conn, Routes.deposit_path(conn, :delete, deposit))
      assert redirected_to(conn) == Routes.deposit_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.deposit_path(conn, :show, deposit))
      end
    end
  end

"""
end
