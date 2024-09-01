defmodule GreekCoin.WithdrawTest do
 
  use GreekCoin.DataCase

  alias GreekCoin.Accounts
  alias GreekCoin.Account.User
  alias GreekCoin.Funds
  alias GreekCoin.Accounting.OperationAccount
  alias GreekCoin.Accounting
  alias GreekCoin.Accounting.Inventory

  describe "withdraw test" do 

    test "Transaction when create should be seen in in the withdraw total" do
       {:ok, user} = Accounts.create_user(%{credential: %{email: "test@testinger.com", password: "some pass", clearance_level: 1}})
       assert user.credential.email == "test@testinger.com"
      {:ok, euro} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ZEUR", alias: "EUR",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})

      {:ok, withdraw} = Funds.create_withdraw(%{"ammount" => 500, "currency_id" => euro.id, "user_id" => user.id, "status" => "created"})
      assert withdraw.ammount == 500
      assert withdraw.currency_id == euro.id 
      total = Funds.find_withdraw_total(user.id, euro.id)
      assert total == withdraw.ammount
    end

    test "Transaction when completed should not be seen in in the withdraw total" do
       {:ok, user} = Accounts.create_user(%{credential: %{email: "test@testinger.com", password: "some pass", clearance_level: 1}})
       assert user.credential.email == "test@testinger.com"
      {:ok, euro} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ZEUR", alias: "EUR",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})

      {:ok, withdraw} = Funds.create_withdraw(%{"ammount" => 500, "currency_id" => euro.id, "user_id" => user.id, "status" => "completed"})
      assert withdraw.ammount == 500
      assert withdraw.currency_id == euro.id
      assert withdraw.status == "completed" 
      total = Funds.find_withdraw_total(user.id, euro.id)
      assert total == 0
    end

    test "Transaction when canceled should not be seen in in the withdraw total" do
       {:ok, user} = Accounts.create_user(%{credential: %{email: "test@testinger.com", password: "some pass", clearance_level: 1}})
       assert user.credential.email == "test@testinger.com"
      {:ok, euro} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ZEUR", alias: "EUR",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})

      {:ok, withdraw} = Funds.create_withdraw(%{"ammount" => 500, "currency_id" => euro.id, "user_id" => user.id, "status" => "canceled"})
      assert withdraw.ammount == 500
      assert withdraw.currency_id == euro.id
      assert withdraw.status == "canceled" 
      total = Funds.find_withdraw_total(user.id, euro.id)
      assert total == 0
    end

  end

end
