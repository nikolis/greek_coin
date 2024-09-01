defmodule GreekCoinWeb.AcceptanceTest do

  use GreekCoinWeb.ConnCase 

  alias GreekCoin.Funds
  alias GreekCoin.Accounting.OperationAccount
  alias GreekCoin.Accounts

  @create_attrs %{ammount: 100000, status: "some status"}



  describe "normal user user case" do
    test "user should be able to create a deposit fullfill it then create transaction and lastly withdraw the money into a personal account" do
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur", decimals: 2, withdraw_fee: 15.0, alias_sort: "EUR", active_deposit: true})
      {:ok, currency1} = Funds.create_currency(%{"title" => "XXBT", "active" => true , "fee" => "3", "active_deposit" => true, "decimals" => 5 , "alias" => "Bitcoin", "withdraw_fee" => 0.0015})
      {:ok, action} = Funds.create_action(%{title: "Buy"})

      {:ok, %OperationAccount{} = operation_acccount} = GreekCoin.Accounting.create_operation_acccount(%{description: "some desc", src: "some src", title: "title", url: "url"})

      {:ok, wallet} = GreekCoin.Funds.create_bank_details(%{currency_id: eur.id, operation_account_id: operation_acccount.id, beneficiary_name: "somekewywyueafdsf", iban: "ADFAF32F23FAFFA", acount_no: "5343242", name: "pireos", swift_code: "some swift"})

      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal23@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "kyc_complient", role: "admin", clearance_level: 1})

      attrs =  Map.merge(@create_attrs, %{currency_id:  eur.id, bank_details_id: wallet.id, status: "created", user_id: user.id})

      conn2 = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})

      body = json_response(conn2, 200)
      conn = recycle(conn2)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"]) ) 

      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs )
      deposit = json_response(conn, 201)
      assert deposit["ammount"] ==  100000
    end
  end

end
