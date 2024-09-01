defmodule GreekCoin.FundsTest do
  use GreekCoin.DataCase

  alias GreekCoin.Funds
  alias GreekCoin.Accounts

  describe "currencies" do
    alias GreekCoin.Funds.Currency

    @valid_attrs %{description: "some description", title: "some title", url: "some url"}
    @update_attrs %{description: "some updated description", title: "some updated title", url: "some updated url"}
    @invalid_attrs %{description: nil, title: nil, url: nil}

    def currency_fixture(attrs \\ %{}) do
      {:ok, currency} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Funds.create_currency()

      currency
    end

    test "list_currencies/0 returns all currencies" do
      currency = currency_fixture()
      #assert Funds.list_currencies() == [currency]
    end

    test "get_currency!/1 returns the currency with given id" do
      currency = currency_fixture()
      assert Funds.get_currency!(currency.id) == currency
    end

    test "create_currency/1 with valid data creates a currency" do
      assert {:ok, %Currency{} = currency} = Funds.create_currency(@valid_attrs)
      assert currency.description == "some description"
      assert currency.title == "some title"
      assert currency.url == "some url"
    end

    test "create_currency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_currency(@invalid_attrs)
    end

    test "update_currency/2 with valid data updates the currency" do
      currency = currency_fixture()
      assert {:ok, %Currency{} = currency} = Funds.update_currency(currency, @update_attrs)
      assert currency.description == "some updated description"
      assert currency.title == "some updated title"
      assert currency.url == "some updated url"
    end

    test "update_currency/2 with invalid data returns error changeset" do
      currency = currency_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_currency(currency, @invalid_attrs)
      assert currency == Funds.get_currency!(currency.id)
    end

    test "delete_currency/1 deletes the currency" do
      currency = currency_fixture()
      assert {:ok, %Currency{}} = Funds.delete_currency(currency)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_currency!(currency.id) end
    end

    test "change_currency/1 returns a currency changeset" do
      currency = currency_fixture()
      assert %Ecto.Changeset{} = Funds.change_currency(currency)
    end
  end

  describe "trasuries" do
    alias GreekCoin.Funds.Treasury

    @valid_attrs %{balance: 120.5}
    @update_attrs %{balance: 456.7}
    @invalid_attrs %{balance: nil}

    def treasury_fixture(attrs \\ %{}) do
      {:ok, user} = Accounts.create_user(%{user_name: "so username1234", credential: %{email: "nikolisgal1234@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified", role: "admin"})

      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur", decimals: 2})

      attrs =  Map.merge(@valid_attrs, %{currency_id: eur.id, user_id: user.id})

      {:ok, treasury} =
        attrs
        |> Enum.into(attrs)
        |> Funds.create_treasury()

      treasury
    end

    test "list_trasuries/0 returns all trasuries" do
      treasury = treasury_fixture()
      assert Funds.list_treasuries() == [treasury]
    end

    test "get_treasury!/1 returns the treasury with given id" do
      treasury = treasury_fixture()
      assert Funds.get_treasury!(treasury.id) == treasury
    end

    test "create_treasury/1 with valid data creates a treasury" do
      {:ok, user} = Accounts.create_user(%{user_name: "so username23", credential: %{email: "nikolisgal2345@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified", role: "admin"})

      {:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR", alias: "Eur", decimals: 2})

      attrs =  Map.merge(@valid_attrs, %{currency_id: eur.id, user_id: user.id})


      assert {:ok, %Treasury{} = treasury} = Funds.create_treasury(attrs)
      assert treasury.balance == 120.5
    end

    test "create_treasury/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_treasury(@invalid_attrs)
    end

    test "update_treasury/2 with valid data updates the treasury" do
      treasury = treasury_fixture()
      assert {:ok, %Treasury{} = treasury} = Funds.update_treasury(treasury, @update_attrs)
      assert treasury.balance == 456.7
    end

    test "update_treasury/2 with invalid data returns error changeset" do
      treasury = treasury_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_treasury(treasury, @invalid_attrs)
      assert treasury == Funds.get_treasury!(treasury.id)
    end

    test "delete_treasury/1 deletes the treasury" do
      treasury = treasury_fixture()
      assert {:ok, %Treasury{}} = Funds.delete_treasury(treasury)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_treasury!(treasury.id) end
    end

    test "change_treasury/1 returns a treasury changeset" do
      treasury = treasury_fixture()
      assert %Ecto.Changeset{} = Funds.change_treasury(treasury)
    end
  end

  describe "request_transactions" do
    alias GreekCoin.Funds.RequestTransaction

    #user = user_fixture()
    #currency = currency_fixture()

    @valid_attrs %{exchange_rate: 120.5, src_amount: 120.5, status: "some status"}
    @update_attrs %{exchange_rate: 456.7, src_amount: 456.7, status: "some updated status"}
    @invalid_attrs %{exchange_rate: nil, src_amount: nil, status: nil}


    def request_transaction_fixture(attrs \\ %{}) do
      result  =
        attrs
        |> Enum.into(@valid_attrs)
        |> Funds.create_request_transaction()
      case result do
         {:ok, request_transaction} ->
           Repo.preload(request_transaction, [:user, :action])
         {:error, changeset} ->
           {:error, changeset} 
      end
    end

    test "list_request_transactions/0 returns all request_transactions" do
      request_transaction = request_transaction_fixture()
      assert Funds.list_request_transactions() == [request_transaction]
    end

    test "get_request_transaction!/1 returns the request_transaction with given id" do
      request_transaction = request_transaction_fixture()
      assert Funds.get_request_transaction!(request_transaction.id) == request_transaction
    end

    test "create_request_transaction/1 with valid data creates a request_transaction" do
      assert {:ok, %RequestTransaction{} = request_transaction} = Funds.create_request_transaction(@valid_attrs)
      assert request_transaction.exchange_rate == 120.5
      assert request_transaction.src_amount == 120.5
      assert request_transaction.status == "some status"
    end

    test "create_request_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_request_transaction(@invalid_attrs)
    end

    test "update_request_transaction/2 with valid data updates the request_transaction" do
      request_transaction = request_transaction_fixture()
      assert {:ok, %RequestTransaction{} = request_transaction} = Funds.update_request_transaction(request_transaction, @update_attrs)
      assert request_transaction.exchange_rate == 456.7
      assert request_transaction.src_amount == 456.7
      assert request_transaction.status == "some updated status"
    end

    test "update_request_transaction/2 with invalid data returns error changeset" do
      request_transaction = request_transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_request_transaction(request_transaction, @invalid_attrs)
      assert request_transaction == Funds.get_request_transaction!(request_transaction.id)
    end

    test "delete_request_transaction/1 deletes the request_transaction" do
      request_transaction = request_transaction_fixture()
      assert {:ok, %RequestTransaction{}} = Funds.delete_request_transaction(request_transaction)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_request_transaction!(request_transaction.id) end
    end

    test "change_request_transaction/1 returns a request_transaction changeset" do
      request_transaction = request_transaction_fixture()
      assert %Ecto.Changeset{} = Funds.change_request_transaction(request_transaction)
    end
  end

  describe "deposits" do
    alias GreekCoin.Funds.Deposit

    @valid_attrs %{ammount: 120.5, status: "some status"}
    @update_attrs %{ammount: 456.7, status: "some updated status"}
    @invalid_attrs %{ammount: nil, status: nil}

    @valid_attrs_user %{credential: %{email: "some@email.com", password: "123456",password_confirmation: "123456"}}


    def user_fixture(_attrs \\ %{}) do
      {:ok, user} =
         Accounts.create_user(@valid_attrs_user)
      user
    end

    def deposit_fixture(_attrs \\ %{}) do
      user = user_fixture()
      currency = currency_fixture()
      wallet = wallet_fixture()
      valid = Map.merge(@valid_attrs, %{user_id: user.id, currency_id: currency.id, status: "created", wallet_id: wallet.id})
      {:ok, deposit} =
         Funds.create_deposit_crypto(valid, "alias2")
      Repo.preload(deposit, [:bank_details, :wallet, :user])
    end

    test "list_deposits/0 returns all deposits" do
      deposit = deposit_fixture()
      assert Funds.list_deposits() == [deposit]
    end

    test "get_deposit!/1 returns the deposit with given id" do
      deposit = deposit_fixture()
      assert Funds.get_deposit!(deposit.id) == deposit
    end

    test "create_deposit/1 with valid data creates a deposit" do
      user = user_fixture()
      currency = currency_fixture()
      wallet = wallet_fixture()
      assert {:ok, %Deposit{} = deposit} = Funds.create_deposit_crypto(%{currency_id: currency.id, user_id: user.id, status: "some status", ammount: 120.5, wallet_id: wallet.id}, "some alias")
      assert deposit.ammount == 120.5
      assert deposit.status == "some status"
    end

    test "create_deposit/1 need at least on of user wallet or user _bank details" do
      user = user_fixture()
      currency = currency_fixture()
      assert {:error, %Ecto.Changeset{} = deposit} = Funds.create_deposit_crypto(%{currency_id: currency.id, user_id: user.id, status: "some status", ammount: 120.5}, "some alias")
    end



    test "create_deposit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_deposit_crypto(@invalid_attrs)
    end

    test "update_deposit/2 with valid data updates the deposit" do
      deposit = deposit_fixture()
      assert {:ok, %Deposit{} = deposit} = Funds.update_deposit(deposit, @update_attrs)
      assert deposit.ammount == 456.7
      assert deposit.status == "some updated status"
    end

    test "update_deposit/2 with invalid data returns error changeset" do
      deposit = deposit_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_deposit(deposit, @invalid_attrs)
      assert deposit == Funds.get_deposit!(deposit.id)
    end

    test "delete_deposit/1 deletes the deposit" do
      deposit = deposit_fixture()
      assert {:ok, %Deposit{}} = Funds.delete_deposit(deposit)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_deposit!(deposit.id) end
    end

    test "change_deposit/1 returns a deposit changeset" do
      deposit = deposit_fixture()
      assert %Ecto.Changeset{} = Funds.change_deposit(deposit)
    end
  end

  describe "actions" do
    alias GreekCoin.Funds.Action

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def action_fixture(attrs \\ %{}) do
      {:ok, action} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Funds.create_action()

      action
    end

    test "get_action!/1 returns the action with given id" do
      action = action_fixture()
      assert Funds.get_action!(action.id) == action
    end

    test "create_action/1 with valid data creates a action" do
      assert {:ok, %Action{} = action} = Funds.create_action(@valid_attrs)
      assert action.title == "some title"
    end

    test "create_action/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_action(@invalid_attrs)
    end

    test "update_action/2 with valid data updates the action" do
      action = action_fixture()
      assert {:ok, %Action{} = action} = Funds.update_action(action, @update_attrs)
      assert action.title == "some updated title"
    end

    test "update_action/2 with invalid data returns error changeset" do
      action = action_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_action(action, @invalid_attrs)
      assert action == Funds.get_action!(action.id)
    end

    test "delete_action/1 deletes the action" do
      action = action_fixture()
      assert {:ok, %Action{}} = Funds.delete_action(action)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_action!(action.id) end
    end

    test "change_action/1 returns a action changeset" do
      action = action_fixture()
      assert %Ecto.Changeset{} = Funds.change_action(action)
    end
  end

  describe "bank_details" do
    alias GreekCoin.Funds.BankDetails

    @valid_attrs %{acount_no: "some acount_no", beneficiary_name: "some beneficiary_name", iban: "some iban", name: "some name", swift_code: "some swift_code"}
    @update_attrs %{acount_no: "some updated acount_no", beneficiary_name: "some updated beneficiary_name", iban: "some updated iban", name: "some updated name", swift_code: "some updated swift_code"}
    @invalid_attrs %{acount_no: nil, beneficiary_name: nil, iban: nil, name: nil, swift_code: nil}

    def bank_details_fixture(attrs \\ %{}) do
      {:ok, account} = GreekCoin.Accounting.create_operation_acccount(%{"title" => "title some"})
      valid_attrs = Map.merge(@valid_attrs, %{operation_account_id: account.id})
      {:ok, bank_details} =
        attrs
        |> Enum.into(valid_attrs)
        |> Funds.create_bank_details()

      Repo.preload(bank_details, :country)
    end

    test "list_bank_details/0 returns all bank_details" do
      bank_details = bank_details_fixture()
      bank_details = GreekCoin.Repo.preload(bank_details, :operation_account)
      assert Funds.list_bank_details() == [bank_details]
    end

    test "get_bank_details!/1 returns the bank_details with given id" do
      bank_details = bank_details_fixture()
      assert Funds.get_bank_details!(bank_details.id) == bank_details
    end

    test "create_bank_details/1 with valid data creates a bank_details" do
      {:ok, account} = GreekCoin.Accounting.create_operation_acccount(%{"title" => "account_title"})
      valida_attrs = Map.merge(@valid_attrs, %{operation_account_id: account.id})
      assert {:ok, %BankDetails{} = bank_details} = Funds.create_bank_details(valida_attrs)
      assert bank_details.acount_no == "some acount_no"
      assert bank_details.beneficiary_name == "some beneficiary_name"
      assert bank_details.iban == "some iban"
      assert bank_details.name == "some name"
      assert bank_details.swift_code == "some swift_code"
    end

    test "create_bank_details/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_bank_details(@invalid_attrs)
    end

    test "update_bank_details/2 with valid data updates the bank_details" do
      bank_details = bank_details_fixture()
      assert {:ok, %BankDetails{} = bank_details} = Funds.update_bank_details(bank_details, @update_attrs)
      assert bank_details.acount_no == "some updated acount_no"
      assert bank_details.beneficiary_name == "some updated beneficiary_name"
      assert bank_details.iban == "some updated iban"
      assert bank_details.name == "some updated name"
      assert bank_details.swift_code == "some updated swift_code"
    end

    test "update_bank_details/2 with invalid data returns error changeset" do
      bank_details = bank_details_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_bank_details(bank_details, @invalid_attrs)
      assert bank_details == Funds.get_bank_details!(bank_details.id)
    end

    test "delete_bank_details/1 deletes the bank_details" do
      bank_details = bank_details_fixture()
      assert {:ok, %BankDetails{}} = Funds.delete_bank_details(bank_details)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_bank_details!(bank_details.id) end
    end

    test "change_bank_details/1 returns a bank_details changeset" do
      bank_details = bank_details_fixture()
      assert %Ecto.Changeset{} = Funds.change_bank_details(bank_details)
    end
  end

  describe "wallets" do
    alias GreekCoin.Funds.Wallet

    @valid_attrs %{additional_info: "some additional_info", private_key: "some private_key", public_key: "some public_key"}
    @update_attrs %{additional_info: "some updated additional_info", private_key: "some updated private_key", public_key: "some updated public_key"}
    @invalid_attrs %{additional_info: nil, private_key: nil, public_key: nil}

    def wallet_fixture(_attrs \\ %{}) do

      currency = currency_fixture()
      {:ok, operation_account} = GreekCoin.Accounting.create_operation_acccount(%{"title" => "oa_title"})
      valid = Map.merge(@valid_attrs,%{ currency_id: currency.id})
      valid = Map.merge(valid, %{operation_account_id: operation_account.id})
      {:ok, wallet} =
         Funds.create_wallet(valid)
      Repo.preload(wallet, :currency)

    end

    test "list_wallets/0 returns all wallets" do
      wallet = wallet_fixture()
      assert Funds.list_wallets() == [wallet]
    end

    test "get_wallet!/1 returns the wallet with given id" do
      wallet = wallet_fixture()
      assert Funds.get_wallet!(wallet.id) == wallet
    end

    test "create_wallet/1 with valid data creates a wallet" do
      currency = currency_fixture()
      {:ok, operation_account} = GreekCoin.Accounting.create_operation_acccount(%{"title" => "oa_fsdfafsdfe"})
      valid_attrs = Map.merge(@valid_attrs, %{operation_account_id: operation_account.id})
      assert {:ok, %Wallet{} = wallet} = Funds.create_wallet(Map.merge(%{currency_id: currency.id},valid_attrs))
      assert wallet.additional_info == "some additional_info"
      assert wallet.private_key == "some private_key"
      assert wallet.public_key == "some public_key"
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_wallet(@invalid_attrs)
    end

    test "update_wallet/2 with valid data updates the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{} = wallet} = Funds.update_wallet(wallet, @update_attrs)
      assert wallet.additional_info == "some updated additional_info"
      assert wallet.private_key == "some updated private_key"
      assert wallet.public_key == "some updated public_key"
    end

    test "update_wallet/2 with invalid data returns error changeset" do
      wallet = wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_wallet(wallet, @invalid_attrs)
      assert wallet == Funds.get_wallet!(wallet.id)
    end

    test "delete_wallet/1 deletes the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{}} = Funds.delete_wallet(wallet)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_wallet!(wallet.id) end
    end

    test "change_wallet/1 returns a wallet changeset" do
      wallet = wallet_fixture()
      assert %Ecto.Changeset{} = Funds.change_wallet(wallet)
    end
  end

  describe "withdrawals" do
    alias GreekCoin.Funds.Withdraw

    @valid_attrs %{ammount: 120.5}
    @update_attrs %{ammount: 456.7}
    @invalid_attrs %{ammount: nil}

    def withdraw_fixture(attrs \\ %{}) do
      {:ok, withdraw} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Funds.create_withdraw()

      Repo.preload(withdraw, [:currency, :user, :user_bank_details, :user_wallet])
    end

    test "list_withdrawals/0 returns all withdrawals" do
      withdraw = withdraw_fixture()
      assert Funds.list_withdrawals() == [withdraw]
    end

    test "get_withdraw!/1 returns the withdraw with given id" do
      withdraw = withdraw_fixture()
      assert Funds.get_withdraw!(withdraw.id) == withdraw
    end

    test "create_withdraw/1 with valid data creates a withdraw" do
      assert {:ok, %Withdraw{} = withdraw} = Funds.create_withdraw(@valid_attrs)
      assert withdraw.ammount == 120.5
    end

    test "create_withdraw/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_withdraw(@invalid_attrs)
    end

    test "update_withdraw/2 with valid data updates the withdraw" do
      withdraw = withdraw_fixture()
      assert {:ok, %Withdraw{} = withdraw} = Funds.update_withdraw(withdraw, @update_attrs)
      assert withdraw.ammount == 456.7
    end

    test "update_withdraw/2 with invalid data returns error changeset" do
      withdraw = withdraw_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_withdraw(withdraw, @invalid_attrs)
      assert withdraw == Funds.get_withdraw!(withdraw.id)
    end

    test "delete_withdraw/1 deletes the withdraw" do
      withdraw = withdraw_fixture()
      assert {:ok, %Withdraw{}} = Funds.delete_withdraw(withdraw)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_withdraw!(withdraw.id) end
    end

    test "change_withdraw/1 returns a withdraw changeset" do
      withdraw = withdraw_fixture()
      assert %Ecto.Changeset{} = Funds.change_withdraw(withdraw)
    end
  end

  describe "user_bank_details" do
    alias GreekCoin.Funds.UserBankDetails

    @valid_attrs %{acount_no: "some acount_no", beneficiary_name: "some beneficiary_name", iban: "some iban", name: "some name", swift_code: "some swift_code", status: "created",src_ammount: 50, exchange_rate: 53.43, recipient_address: "some address"}
    @update_attrs %{acount_no: "some updated acount_no", beneficiary_name: "some updated beneficiary_name", iban: "some updated iban", name: "some updated name", swift_code: "some updated swift_code"}
    @invalid_attrs %{acount_no: nil, beneficiary_name: nil, iban: nil, name: nil, swift_code: nil}

    def user_bank_details_fixture(attrs \\ %{}) do
      {:ok, user_bank_details} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Funds.create_user_bank_details()

      user_bank_details
    end

    test "list_user_bank_details/0 returns all user_bank_details" do
      user_bank_details = user_bank_details_fixture()
      assert Funds.list_user_bank_details() == [user_bank_details]
    end

    test "get_user_bank_details!/1 returns the user_bank_details with given id" do
      user_bank_details = user_bank_details_fixture()
      assert Funds.get_user_bank_details!(user_bank_details.id) == user_bank_details
    end

    test "create_user_bank_details/1 with valid data creates a user_bank_details" do
      assert {:ok, %UserBankDetails{} = user_bank_details} = Funds.create_user_bank_details(@valid_attrs)
      assert user_bank_details.acount_no == "some acount_no"
      assert user_bank_details.beneficiary_name == "some beneficiary_name"
      assert user_bank_details.iban == "some iban"
      assert user_bank_details.name == "some name"
      assert user_bank_details.swift_code == "some swift_code"
    end

    test "create_user_bank_details/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_user_bank_details(@invalid_attrs)
    end

    test "update_user_bank_details/2 with valid data updates the user_bank_details" do
      user_bank_details = user_bank_details_fixture()
      assert {:ok, %UserBankDetails{} = user_bank_details} = Funds.update_user_bank_details(user_bank_details, @update_attrs)
      assert user_bank_details.acount_no == "some updated acount_no"
      assert user_bank_details.beneficiary_name == "some updated beneficiary_name"
      assert user_bank_details.iban == "some updated iban"
      assert user_bank_details.name == "some updated name"
      assert user_bank_details.swift_code == "some updated swift_code"
    end

    test "update_user_bank_details/2 with invalid data returns error changeset" do
      user_bank_details = user_bank_details_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_user_bank_details(user_bank_details, @invalid_attrs)
      assert user_bank_details == Funds.get_user_bank_details!(user_bank_details.id)
    end

    test "delete_user_bank_details/1 deletes the user_bank_details" do
      user_bank_details = user_bank_details_fixture()
      result =  Funds.delete_user_bank_details(user_bank_details.id)
      assert {1, _} = result
      assert_raise Ecto.NoResultsError, fn -> Funds.get_user_bank_details!(user_bank_details.id) end
    end

    test "change_user_bank_details/1 returns a user_bank_details changeset" do
      user_bank_details = user_bank_details_fixture()
      assert %Ecto.Changeset{} = Funds.change_user_bank_details(user_bank_details)
    end
  end

  describe "user_wallets" do
    alias GreekCoin.Funds.UserWallet

    @valid_attrs %{bublic_key: "some bublic_key"}
    @update_attrs %{bublic_key: "some updated bublic_key"}
    @invalid_attrs %{bublic_key: nil}

    def user_wallet_fixture(_attrs \\ %{}) do
      user = user_fixture()
      currency = currency_fixture()
      valid = Map.merge(@valid_attrs, %{user_id: user.id, currency_id: currency.id, status: "created"})
      {:ok, user_wallet} =
         Funds.create_user_wallet(valid)
      user_wallet
    end

    test "list_user_wallets/0 returns all user_wallets" do
      user_wallet = user_wallet_fixture()
      assert Funds.list_user_wallets() == [user_wallet]
    end

    test "get_user_wallet!/1 returns the user_wallet with given id" do
      user_wallet = user_wallet_fixture()
      assert Funds.get_user_wallet!(user_wallet.id) == user_wallet
    end

    test "create_user_wallet/1 with valid data creates a user_wallet" do
      assert {:ok, %UserWallet{} = user_wallet} = Funds.create_user_wallet(@valid_attrs)
      assert user_wallet.bublic_key == "some bublic_key"
    end

    test "create_user_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Funds.create_user_wallet(@invalid_attrs)
    end

    test "update_user_wallet/2 with valid data updates the user_wallet" do
      user_wallet = user_wallet_fixture()
      assert {:ok, %UserWallet{} = user_wallet} = Funds.update_user_wallet(user_wallet, @update_attrs)
      assert user_wallet.bublic_key == "some updated bublic_key"
    end

    test "update_user_wallet/2 with invalid data returns error changeset" do
      user_wallet = user_wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Funds.update_user_wallet(user_wallet, @invalid_attrs)
      assert user_wallet == Funds.get_user_wallet!(user_wallet.id)
    end

    test "delete_user_wallet/1 deletes the user_wallet" do
      user_wallet = user_wallet_fixture()
      assert {_, _} = Funds.delete_user_wallet(user_wallet.id)
      assert_raise Ecto.NoResultsError, fn -> Funds.get_user_wallet!(user_wallet.id) end
    end

    test "change_user_wallet/1 returns a user_wallet changeset" do
      user_wallet = user_wallet_fixture()
      assert %Ecto.Changeset{} = Funds.change_user_wallet(user_wallet)
    end
  end
end
