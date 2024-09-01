defmodule GreekCoin.FundsComplexTest do

  use GreekCoin.DataCase, async: true

  alias GreekCoin.Accounts.User
  alias GreekCoin.Accounts
  alias GreekCoin.Funds
  alias GreekCoin.Accounting

  describe "Scenario(dep,exch,withdr)/=>" do

    @valid_attrs %{user_name: "sousername", credential: %{email: "test@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified"}

    test "User registration" do
      assert {:ok, %User{id: id} = user} = Accounts.register_user(@valid_attrs)
      assert user.user_name == "sousername"
      assert user.credential.email == "test@gmail.com"
    end

    test "Currency Creation" do
      
      {:ok, _btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin"})
      {:ok, _eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur"})
 
      eur = Funds.get_currency_by(%{title: "EUR"})
      assert eur.title == "EUR"
    end

    test "treasury creation " do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur"})
      Funds.create_treasury(%{user_id: user.id, currency_id: eur.id , balance: 1000})
      user = Repo.preload(user, [treasuries: :currency])
      assert length(user.treasuries) == 1
      [head | _tail] = user.treasuries
      assert head.balance == 1000
    end

    test "action creation" do
      {:ok, action_buy} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Buy"})
      {:ok, _action_sell} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Sell"})
      assert action_buy.title == "Buy"
    end


    test "validate_transaction Insufficient Funds" do
      #Arrange
      {:ok, user} = Accounts.register_user(@valid_attrs)
      {:ok, btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin"})
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur"})
      {:ok, action_buy} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Buy"})
      {:ok, _action_sell} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Sell"})
      {:ok, _treasur_or} = Funds.create_treasury(%{user_id: user.id, currency_id: eur.id , balance: 1000})
      tr_params = %{"action_id" => action_buy.id, "src_amount"=> 1500, "exchange_rate"=>800,"fee" => 3.5, "src_currency_id" => eur.id, "tgt_currency_id" => btc.id}

      #Act
      {:error, reason} = Funds.validate_transaction(user, tr_params)
      #Assert
      assert reason == :treasury_funds
    end


    test "validate_transaction Sufficient Funds" do
      #Arrange
      {:ok, user} = Accounts.register_user(@valid_attrs)
      {:ok, btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin"})
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur"})
      {:ok, action_buy} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Buy"})
      {:ok, action_sell} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Sell"})
      {:ok, _treasur_or} = Funds.create_treasury(%{user_id: user.id, currency_id: eur.id , balance: 1000})
      tr_params = %{"action_id" => action_buy.id, "src_amount"=> 1, "exchange_rate"=>800,"fee" => 3.5, "src_currency_id" => eur.id, "tgt_currency_id" => btc.id}

      #Act
      {:ok, reason} = Funds.validate_transaction(user, tr_params)
      #Assert
      assert reason.currency_id == eur.id
      assert reason.balance > 800 * 1 + (800*1)* (3.5/100)
    end

    test "validate_transaction InSufficient Funds23" do
      #Arrange
      {:ok, user} = Accounts.register_user(@valid_attrs)
      {:ok, btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin"})
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur"})
      {:ok, _action_buy} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Buy"})
      {:ok, action_sell} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Sell"})
      {:ok, _treasur_or} = Funds.create_treasury(%{user_id: user.id, currency_id: eur.id , balance: 1000})
      tr_params = %{"action_id" => action_sell.id, "src_amount"=> 1, "exchange_rate"=>800,"fee" => 3.5, "src_currency_id" => eur.id, "tgt_currency_id" => btc.id}

      #Act
      {:error, reason} = Funds.validate_transaction(user, tr_params)
      #Assert
      assert reason == :treasury_funds 
    end


    test "Buy transaction handling" do
      #Arrange
      {:ok, user} = Accounts.register_user(@valid_attrs)
      {:ok, btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin", decimals: 5})
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur", decimals: 2})
      {:ok, action_buy} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Buy"})
      {:ok, _action_sell} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Sell"})
      {:ok, _treasur_or} = Funds.create_treasury(%{user_id: user.id, currency_id: eur.id , balance: 1000})
      {:ok, account } = Accounting.create_operation_acccount(%{"title" => "some account"})
      {:ok,  inventory } = Accounting.create_inventory(%{"currency_id" => eur.id, "operation_account_id" => account.id, "balance" => 150}) 
      {:ok,  inventory2 } = Accounting.create_inventory(%{"currency_id" => btc.id, "operation_account_id" => account.id, "balance" => 150}) 


      #Act 
      {:ok, transaction } = Funds.create_request_transaction(%{"user_id" => user.id, "status" => "created", "src_currency_id" => eur.id, "tgt_currency_id" => btc.id, "src_amount"=> 1, "exchange_rate" => 100,"fee"=> 3, "action_id" => action_buy.id})

      #Assert 
      treasury_src = Funds.get_treasury(user.id, eur.id)
      treasury_tgt = Funds.get_treasury(user.id, btc.id)
    end    

    test "Sell transaction handling" do
      #Arrange
      {:ok, user} = Accounts.register_user(@valid_attrs)
      {:ok, btc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BTC", alias: "Bitcoin", decimals: 5})
      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur", decimals: 2})
      {:ok, _action_buy} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Buy"})
      {:ok, action_sell} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Sell"})
      {:ok, _treasur_or} = Funds.create_treasury(%{user_id: user.id, currency_id: btc.id , balance: 20})
      {:ok, account } = Accounting.create_operation_acccount(%{"title" => "some account"})
      {:ok,  inventory } = Accounting.create_inventory(%{"currency_id" => eur.id, "operation_account_id" => account.id, "balance" => 150}) 
      {:ok,  inventory2 } = Accounting.create_inventory(%{"currency_id" => btc.id, "operation_account_id" => account.id, "balance" => 150}) 



      #Act 
      {:ok, transaction } = Funds.create_request_transaction(%{"user_id" => user.id, "status" => "created", "src_currency_id" => eur.id, "tgt_currency_id" => btc.id, "src_amount"=> 1, "exchange_rate" => 100,"fee"=> 3, "action_id" => action_sell.id})
      _result =Funds.handle_transaction(%{"user_id" => user.id, "trans_id" => transaction.id, "end_cost" => 120, "inventory" => inventory, "inventory_to" => inventory2, "operation_account_id" => account.id, "comment" => "some comment"})

      #Assert 
      treasury_src = Funds.get_treasury(user.id, eur.id)
      treasury_tgt = Funds.get_treasury(user.id, btc.id)
      assert is_nil(treasury_src) == false
      assert is_nil(treasury_tgt) == false
      assert treasury_src.balance == 97
      assert treasury_tgt.balance == 19
    end    


  end

end
