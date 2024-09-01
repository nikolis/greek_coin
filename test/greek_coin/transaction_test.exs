defmodule GreekCoin.TransactionTest do

  use GreekCoin.DataCase

  alias GreekCoin.Accounts
  alias GreekCoin.Account.User
  alias GreekCoin.Funds
  alias GreekCoin.Accounting.OperationAccount
  alias GreekCoin.Accounting
  alias GreekCoin.Accounting.Inventory


  describe "transactions Buy" do
    test "transactions Buy" do
      {:ok, user} = Accounts.create_user(%{credential: %{email: "test@testinger.com", password: "some pass", clearance_level: 1}})

      assert user.credential.email == "test@testinger.com"
      {:ok, euro} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ZEUR", alias: "EUR",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})
      {:ok, btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XXBTC", alias: "Bitcoin",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})

      {:ok, action} = Funds.create_action(%{title: "Buy"})
      assert action.title == "Buy"

      {:ok, treasuryEuro} = Funds.create_treasury(%{user_id: user.id, currency_id: euro.id, balance: 100})
      treasuryEuro = GreekCoin.Repo.preload(treasuryEuro, :currency)

      validation = Funds.validate_transaction(user, %{"src_currency_id" => euro.id, "tgt_currency_id" => btc.id, "action_id" => action.id, "src_amount" => 100, "exchange_rate" => 1, "fee" => 3})
     assert  validation == {:ok, treasuryEuro}

      assert {:ok, %OperationAccount{} = operation_acccount} = Accounting.create_operation_acccount(%{description: "some description", src: "some src", title: "some title", url: "some url"})
      assert {:ok, %Inventory{} = inventory} = Accounting.create_inventory(%{"operation_account_id" => operation_acccount.id, "currency_id" => euro.id, "balance" => 100})

      assert {:ok, {%Inventory{} = iventory1, %Inventory{}= inventory2}} = Funds.find_inventories_for_transaction(operation_acccount.id, euro, 1000, btc, 95)

      {:ok, transaction} = Funds.create_request_transaction(%{"user_id" => user.id, "status"=> "created", "exchange_rate" => 1, "src_amount" => 100, "fee" => 3, "action_id" => action.id, "operation_account_id" => operation_acccount.id, "src_currency_id" => euro.id, "tgt_currency_id" => btc.id  })

      {:ok, _resp} = Funds.handle_transaction(%{"user_id" => user.id, "trans_id" => transaction.id, "end_cost" => 95, "inventory" => iventory1, "inventory_to" => inventory2, "operation_account_id" => operation_acccount.id, "comment" => "some comment"})

      treasuryRet1 = Funds.get_treasury(user.id, euro.id)
      treasuryRet2 = Funds.get_treasury(user.id, btc.id)
      assert treasuryRet1.balance == 0
      assert treasuryRet2.balance == 97.0

    end

    test "transactions Sell" do
      {:ok, user} = Accounts.create_user(%{credential: %{email: "test@testinger.com", password: "some pass", clearance_level: 1}})

      assert user.credential.email == "test@testinger.com"
      {:ok, euro} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ZEUR", alias: "EUR",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})
      {:ok, btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XXBTC", alias: "Bitcoin",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})

      {:ok, action} = Funds.create_action(%{title: "Sell"})
      assert action.title == "Sell"

      {:ok, treasuryEuro} = Funds.create_treasury(%{user_id: user.id, currency_id: btc.id, balance: 100})
      treasuryEuro = GreekCoin.Repo.preload(treasuryEuro, :currency)

      validation = Funds.validate_transaction(user, %{"src_currency_id" => euro.id, "tgt_currency_id" => btc.id, "action_id" => action.id, "src_amount" => 100, "exchange_rate" => 1, "fee" => 3})
     assert  validation == {:ok, treasuryEuro}

      assert {:ok, %OperationAccount{} = operation_acccount} = Accounting.create_operation_acccount(%{description: "some description", src: "some src", title: "some title", url: "some url"})
      assert {:ok, %Inventory{} = inventory} = Accounting.create_inventory(%{"operation_account_id" => operation_acccount.id, "currency_id" => btc.id, "balance" => 100})

      assert {:ok, {%Inventory{} = iventory1, %Inventory{}= inventory2}} = Funds.find_inventories_for_transaction(operation_acccount.id, btc, 100, btc, 95)

      {:ok, transaction} = Funds.create_request_transaction(%{"user_id" => user.id, "status"=> "created", "exchange_rate" => 1, "src_amount" => 100, "fee" => 3, "action_id" => action.id, "operation_account_id" => operation_acccount.id, "src_currency_id" => euro.id, "tgt_currency_id" => btc.id  })

      {:ok, _resp} = Funds.handle_transaction(%{"user_id" => user.id, "trans_id" => transaction.id, "end_cost" => 95, "inventory" => iventory1, "inventory_to" => inventory2, "operation_account_id" => operation_acccount.id, "comment" => "some comment"})

      treasuryRet1 = Funds.get_treasury(user.id, euro.id)
      treasuryRet2 = Funds.get_treasury(user.id, btc.id)
      assert treasuryRet1.balance == 97.0
      assert treasuryRet2.balance == 0


    end

    test "transactions Exchange" do
      {:ok, user} = Accounts.create_user(%{credential: %{email: "test@testinger.com", password: "some pass", clearance_level: 1}})

      assert user.credential.email == "test@testinger.com"
      {:ok, euro} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ZEUR", alias: "EUR",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})
      {:ok, btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XXBTC", alias: "Bitcoin",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})

      {:ok, action} = Funds.create_action(%{title: "Exchange"})
      assert action.title == "Exchange"

      {:ok, treasuryEuro} = Funds.create_treasury(%{user_id: user.id, currency_id: euro.id, balance: 100})
      treasuryEuro = GreekCoin.Repo.preload(treasuryEuro, :currency)

      validation = Funds.validate_transaction(user, %{"src_currency_id" => euro.id, "tgt_currency_id" => btc.id, "action_id" => action.id, "src_amount" => 100, "exchange_rate" => 1, "fee" => 3})
     assert  validation == {:ok, treasuryEuro}

      assert {:ok, %OperationAccount{} = operation_acccount} = Accounting.create_operation_acccount(%{description: "some description", src: "some src", title: "some title", url: "some url"})
      assert {:ok, %Inventory{} = inventory} = Accounting.create_inventory(%{"operation_account_id" => operation_acccount.id, "currency_id" => euro.id, "balance" => 100})

      assert {:ok, {%Inventory{} = iventory1, %Inventory{}= inventory2}} = Funds.find_inventories_for_transaction(operation_acccount.id, euro, 1000, btc, 95)

      {:ok, transaction} = Funds.create_request_transaction(%{"user_id" => user.id, "status"=> "created", "exchange_rate" => 1, "src_amount" => 100, "fee" => 3, "action_id" => action.id, "operation_account_id" => operation_acccount.id, "src_currency_id" => euro.id, "tgt_currency_id" => btc.id  })

      {:ok, _resp} = Funds.handle_transaction(%{"user_id" => user.id, "trans_id" => transaction.id, "end_cost" => 95, "inventory" => iventory1, "inventory_to" => inventory2, "operation_account_id" => operation_acccount.id, "comment" => "some comment"})

      treasuryRet1 = Funds.get_treasury(user.id, euro.id)
      treasuryRet2 = Funds.get_treasury(user.id, btc.id)
      assert treasuryRet1.balance == 0
      assert treasuryRet2.balance == 97.0

    end

  end

end
