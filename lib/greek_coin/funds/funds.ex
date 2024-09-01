defmodule GreekCoin.Funds do
  @moduledoc """
  The Funds context.
  """

  import Ecto.Query, warn: false
  alias GreekCoin.Repo

  alias GreekCoin.Funds.Currency
  alias GreekCoin.Funds.Deposit
  alias GreekCoin.Funds.Action
  alias GreekCoin.Funds.Withdraw
  alias GreekCoin.Funds.RequestTransaction
  alias GreekCoin.Accounts
  alias Ecto.Multi
  alias GreekCoin.Funds.Treasury


  def clean_transactions(dateTimeNow, seconds) do
    dateTime = DateTime.add(dateTimeNow, seconds)
    query = from transaction in RequestTransaction
    query = from transaction in query,
      where: transaction.inserted_at <= ^dateTime

    query = from transaction in query,
      where: transaction.status == "Verification required"

    Repo.delete_all query
  end

  def clean_withdraws(dateTimeNow, seconds) do
    dateTime = DateTime.add(dateTimeNow, seconds)
    query = from transaction in Withdraw
    query = from transaction in query,
      where: transaction.inserted_at <= ^dateTime

    query = from transaction in query,
      where: transaction.status == "created" or transaction.status == "2fa needed"

    withdraws = 
       query
       |> Repo.all 
       |> Repo.preload([:user_wallet, :user_bank_details])

    Enum.each(withdraws, fn withd ->
      if !is_nil(withd.user_wallet) do
        delete_user_wallet(withd.user_wallet.id)
      end
      if !is_nil(withd.user_bank_details) do
        delete_user_bank_details(withd.user_bank_details.id)
      end
      delete_withdraw(withd)
    end)
  end


  def get_withdrawall_count(status) do
    if (status == "all") do
       result = from(withd in Withdraw, select: count(withd.id))
       |> Repo.all
       [head | _tail] = result
       head
    else 
      result = from(withd in Withdraw, where: like(withd.status, ^status), select: count(withd.id)
      )
      |> Repo.all
      [head | _tail] = result
      head
    end
  end

  def count_user_deposits(user_id) do
    result = 
    from(deposit in Deposit, 
      where: deposit.user_id == ^user_id  and deposit.status == "created",
      select: count(deposit.id))
      |> Repo.all
    [head | _tail] = result 
    head
  end 

   def get_deposit_count(status) do
    if (status == "all") do
       result = from(deposit in Deposit, select: count(deposit.id))
       |> Repo.all
       [head | _tail] = result
       head
    else 
      result = from(deposit in Deposit, where: like(deposit.status, ^status), select: count(deposit.id)
      )
      |> Repo.all
      [head | _tail] = result
      head
    end
  end

  def get_transaction_request_count(status, action_id) do
    if (action_id == "0" or action_id == 0) do
      if(status == "all") do
        result = from( tr in RequestTransaction, select: count(tr.id))
          |> Repo.all
          [head  | _tail] = result
        head
      else 
        result = from(tr in RequestTransaction, where: like(tr.status, ^status), select: count(tr.id))
          |> Repo.all
          [head | _tail] = result
          head
      end
    else
      if(status == "all") do
        result = from( tr in RequestTransaction, where: tr.action_id == ^action_id, select: count(tr.id))
          |> Repo.all
          [head  | _tail] = result
        head
      else 
        result = from(tr in RequestTransaction, where: like(tr.status, ^status) and tr.action_id == ^action_id, select: count(tr.id))
          |> Repo.all
          [head | _tail] = result
          head
      end
    end
  end

  def find_withdraw_total(user_id, currency_id) do
    withdraws = get_withdraw(user_id, currency_id)
    withdraws = Enum.filter(withdraws, fn withd -> withd.status != "completed" && withd.status != "canceled" end)
    result = List.foldl(withdraws, 0, fn wit, acc-> wit.ammount + acc end)
    result
  end


  def validate_transaction(user, tr_params) do
    src_currency_id = Map.get(tr_params, "src_currency_id")
    tgt_currency_id = Map.get(tr_params, "tgt_currency_id")
    action_id = Map.get(tr_params, "action_id")
    src_amount = Map.get(tr_params, "src_amount")
    _exchange_rate = Map.get(tr_params, "exchange_rate")
    _fee = Map.get(tr_params, "fee")

    action = get_action!(action_id)
    if(is_nil(action)) do
      {:error, "Invalid Argument Error"}
    else
      case action.title do
        "Buy" ->
          #price = calculate_price(:Buy, src_amount, exchange_rate, fee) 
          find_treasury_for_transaction(src_amount, src_currency_id, user.id) 

        "Sell" ->
          find_treasury_for_transaction(src_amount, tgt_currency_id, user.id) 

        "Exchange" ->
          #price = calculate_price(:Buy, src_amount, exchange_rate, fee) 
          find_treasury_for_transaction(src_amount, src_currency_id,user.id) 

        _ ->
          {:error, "Unknown action"}
      end

    end

  end

  def find_inventories_for_transaction(operation_account_id, src_currency, _ammount, tgt_currency, actuall) do
    operationAccount = GreekCoin.Accounting.get_operation_acccount!(operation_account_id) 
    #currency switch
    retList = Enum.filter(operationAccount.inventories, fn x -> (x.currency_id == src_currency.id and x.balance >= actuall) end)
    if(Enum.empty?(retList)) do
      {:error, "not enough funds in the account"}
    else
      [head | _tail] =  retList
      result = Enum.filter(operationAccount.inventories, fn x -> (x.currency_id == tgt_currency.id) end) 
      if(Enum.empty?(result)) do
         case GreekCoin.Accounting.create_inventory(%{"balance" => 0, "currency_id" => tgt_currency.id, "operation_account_id" => operation_account_id}) do
              {:ok, inventory_to} ->
                  {:ok, {head , inventory_to}}
              {:error, error } ->
                  {:error, error}
         end
      else
          [head2 | _tail2] = result
          {:ok, {head, head2}}
      end
    end 
  end

  def find_inventories_for_sell_transaction(operation_account_id, src_currency, ammount, tgt_currency, _actuall) do

    operationAccount = GreekCoin.Accounting.get_operation_acccount!(operation_account_id) 
    retList = Enum.filter(operationAccount.inventories, fn x -> (x.currency_id == tgt_currency.id and x.balance >= ammount) end)

    if(Enum.empty?(retList)) do
      {:error, "not enough funds in the account"}
    else
      [head | _tail] =  retList
      result = Enum.filter(operationAccount.inventories, fn x -> (x.currency_id == src_currency.id) end) 
      if(Enum.empty?(result)) do
         case GreekCoin.Accounting.create_inventory(%{"balance" => 0, "currency_id" => src_currency.id, "operation_account_id" => operation_account_id}) do
              {:ok, inventory_to} ->
                  {:ok, {head , inventory_to}}
              {:error, error } ->
                  {:error, error}
         end
      else
          [head2 | _tail] = result
          {:ok, {head, head2}}
      end
    end 
  end

  def find_treasury_for_transaction(price, currency_id, user_id) do
      treasury = get_treasury(user_id, currency_id)
      if(is_nil(treasury)) do
          {:error, :treasury_funds}
      else
        if(treasury.balance< price) do
           {:error, :treasury_funds}
        else
          totalWithdraw = find_withdraw_total(user_id, currency_id)
          if(treasury.balance  < price + totalWithdraw)  do
            {:error, :treasury_funds_withdraw}
          else
            {:ok, treasury}
          end
        end
      end
  end

  def get_or_create_tgt_treasury(currency, user_id) do
    treasury = get_treasury(user_id, currency.id)
    if(is_nil(treasury)) do
      case create_treasury(%{user_id: user_id, currency_id: currency.id, balance: 0.0})  do
        {:ok, treasury} ->
          treasury = Repo.preload(treasury, :currency)
          {:ok, treasury}
        {:err, %Ecto.Changeset{} = _changeset} ->
          {:error, :treasury_empty}
      end
    else
      {:ok, treasury}
    end
  end

  def calculate_price(type, ammount, rate, fee) do
    case type do
      :Sell ->
          compound = ammount * rate
          price = compound - (compound * (fee/100))
          price

      :Buy ->
          unit_cost = rate
          units = ammount/unit_cost
          (units - (units* (fee/100)))
    end
  end

  def handle_transaction(%{"user_id" => user_id, "trans_id" => trans_id, "end_cost" => end_cost, "inventory" => inventory, "inventory_to" => inventory_to, "operation_account_id" => operation_account_id, "comment" => comment}) do

    transaction  = get_request_transaction!(trans_id)
    src_currency = transaction.src_currency
    tgt_currency = transaction.tgt_currency
    user = Accounts.get_user!(user_id)
    case transaction.action.title do
      "Sell" ->
        price = calculate_price(:Sell, transaction.src_amount, transaction.exchange_rate, transaction.fee)
        treasuryResult = find_treasury_for_transaction(transaction.src_amount, tgt_currency.id, user.id)

        case treasuryResult do
          {:error, error_type} ->
            {:erro, error_type}

          {:ok, treasury_tgt} ->
            case get_or_create_tgt_treasury(src_currency, user.id) do 
              {:error, error_type} ->
                {:error, error_type}
              {:ok, treasury} ->
                  remaining = Float.round(treasury_tgt.balance - transaction.src_amount, treasury_tgt.currency.decimals)
                  total = Float.round(treasury.balance + price , treasury.currency.decimals)
                  
                  result = 
                    Multi.new()
                    |> Multi.update(:tgt_treasury, Treasury.changeset(treasury_tgt, %{"balance" => remaining }))
                    |> Multi.update(:src_treasury, Treasury.changeset(treasury, %{"balance"=> total}))
                    |> Multi.update(:status, RequestTransaction.changeset(transaction, %{"status" => "completed", "operation_account_id" => operation_account_id, "end_cost" => end_cost, "comment" => comment}))
                    |> Multi.update(:account_from, GreekCoin.Accounting.Inventory.changeset(inventory, %{"balance" => inventory.balance+end_cost}))
                    |> Multi.update(:account_to, GreekCoin.Accounting.Inventory.changeset(inventory_to, %{"balance" => inventory_to.balance - transaction.src_amount}))
                    |> Repo.transaction 
                   case result do
                      {:ok, _record} ->
                        transaction = get_request_transaction!(transaction.id)
                        {:ok, transaction}
                      {_, error} ->
                        {:err, error} 
                   end        
            end
        end

      _ -> 
          units = calculate_price(:Buy, transaction.src_amount, transaction.exchange_rate, transaction.fee)
          treasuryResult = find_treasury_for_transaction(transaction.src_amount, src_currency.id, user.id)
          case treasuryResult do
            {:error, treasury_funds} ->
                {:error, treasury_funds}
            {:ok, treasury} ->
              case get_or_create_tgt_treasury(tgt_currency, user.id) do
                {:ok, treasury_tgt} ->
                  subRemain = treasury.balance - transaction.src_amount
                  remain = Float.round(subRemain, treasury.currency.decimals)
                  unitsRound = Float.round(units, treasury_tgt.currency.decimals)
                  #  total = Float.round(transaction.src_amount, src_currency.decimals)
                    result = 
                      Multi.new()
                      |> Multi.update(:src_treasury, Treasury.changeset(treasury, %{"balance"=> remain}))
                      |> Multi.update(:tgt_treasury, Treasury.changeset(treasury_tgt, %{"balance" => unitsRound+ treasury_tgt.balance}))
                      |> Multi.update(:status, RequestTransaction.changeset(transaction, %{"status" => "completed", "operation_account_id" => operation_account_id, "end_cost" => end_cost, "comment" => comment}))
                      |> Multi.update(:account_from, GreekCoin.Accounting.Inventory.changeset(inventory, %{"balance" => inventory.balance-end_cost}))
                      |> Multi.update(:account_to, GreekCoin.Accounting.Inventory.changeset(inventory_to, %{"balance" => inventory_to.balance + unitsRound}))
                      |> Repo.transaction
                    case result do
                      {:ok, _record} ->
                        transaction = get_request_transaction!(transaction.id)
                        {:ok, transaction}
                      {_, error} ->
                        {:err, error} 
                    end
              end
          end
    end
  end

  def change_withdraw(%Withdraw{} = withdraw) do
    Withdraw.changeset(withdraw, %{})
  end

  def delete_withdraw(%Withdraw{} = withdraw) do
    Repo.delete(withdraw)
  end

  def update_withdraw(%Withdraw{} = withdraw, attrs) do
    withdraw
    |> Withdraw.changeset(attrs)
    |> Repo.update()
  end

  def mark_withdrawall_as_email_verified(%Withdraw{} = withdraw) do
    #update_user = %User{user | status: "email_verified"}
    withdraw = get_withdraw!(withdraw.id)
    withdraw
    |> Withdraw.changeset(%{status: "email_verified"})
    |> Repo.update()
  end 


  def create_withdraw(attrs \\ %{}) do
    %Withdraw{}
    |> Withdraw.changeset(attrs)
    |> Repo.insert()
  end

  def get_withdraw!(id) do
    Repo.get!(Withdraw, id)
    |> Repo.preload([:user, :currency, :user_bank_details, :user_wallet])
  end

  def get_withdraw(user_id, currency_id) do
    query = 
      from withD in Withdraw,
      where: withD.user_id == ^user_id
      and withD.currency_id == ^currency_id
    Repo.all query
  end


  def list_withdrawals_per_user(user_id) do
    from(withdraw in Withdraw,
      where: withdraw.user_id == ^user_id)
    |> Repo.all 
    |> Repo.preload([:user, :currency, :user_bank_details, :user_wallet])
  end

  def list_withdrawals_per_user_currency(user_id, currency_id) do
    from(withdraw in Withdraw,
      where: withdraw.user_id == ^user_id and withdraw.currency_id == ^currency_id)
    |> Repo.all
    |> Repo.preload([:user, :currency, :user_bank_details, :user_wallet])
  end

  def list_withdrawals do
    Repo.all(Withdraw)
    |> Repo.preload([:user, :currency, :user_bank_details, :user_wallet])
  end

  def list_actions do
    Repo.all(Action)
  end


  def list_pending_deposits do
    query =  from(deposit in Deposit,
      where: deposit.status == "created")
    result = Repo.all query
    Repo.preload(result, [:currency, :wallet, :bank_details])
  end

  def list_deposits do
    Repo.all(Deposit)
    |> Repo.preload([:currency, :wallet, :bank_details, :user])
  end

  def list_user_deposits(user_id) do
    from(deposit in Deposit,
      where: deposit.user_id == ^user_id)
    |> Repo.all
    |> Repo.preload([:currency, :wallet, :bank_details])
  end


  def get_deposit!(id) do
    Repo.get!(Deposit, id)
    |> Repo.preload([:currency, :user, :wallet, :bank_details])
  end

  def create_deposit_monetary(attrs \\ %{}, alia) do
    result =  
      %Deposit{}
      |> Deposit.changeset_monetary(attrs)
      |> Repo.insert()
    case result do 
      {:ok, deposit} ->
        if(is_nil(alia) or String.length(alia) == 0 ) do
          deposit = Repo.preload(deposit, [:currency, :wallet, :bank_details])
          {:ok, deposit}
        else
         result = 
          deposit
           |> Deposit.changeset_monetary(%{"alias" => alia <> Integer.to_string(deposit.id)  })
           |> Repo.update
          case result do
            {:ok, deposit} ->
              deposit = Repo.preload(deposit, [:currency, :wallet, :bank_details])
              {:ok, deposit}
            {:error, changeset} ->
              {:error, changeset}
          end
        end
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def create_deposit_crypto(attrs \\ %{}, alia) do
    result =  
      %Deposit{}
      |> Deposit.changeset_crypto(attrs)
      |> Repo.insert()
    case result do 
      {:ok, deposit} ->
        if(is_nil(alia) or String.length(alia) == 0 ) do
          deposit = Repo.preload(deposit, [:currency, :wallet, :bank_details])
          {:ok, deposit}
        else
         result = 
          deposit
           |> Deposit.changeset_crypto(%{"alias" => alia <> Integer.to_string(deposit.id)  })
           |> Repo.update
          case result do
            {:ok, deposit} ->
              deposit = Repo.preload(deposit, [:currency, :wallet, :bank_details])
              {:ok, deposit}
            {:error, changeset} ->
              {:error, changeset}
          end
        end
      {:error, changeset} ->
        {:error, changeset}
    end
  end


  def update_deposit(%Deposit{} = deposit, attrs) do
    result  = 
      deposit
      |> Deposit.changeset(attrs)
      |> Repo.update()
    case result do
      {:ok, deposit} ->
        {:ok, Repo.preload(deposit, [:user, :wallet, :bank_details])}
      {:error, changeset} ->
        {:error, changeset}
    end 
  end

  def delete_deposit(%Deposit{} = deposit) do
    Repo.delete(deposit)
  end

  def change_deposit(%Deposit{} = deposit) do
    Deposit.changeset(deposit, %{})
  end

  def list_currencies do
    Repo.all(Currency)
  end

  def list_all_active_currencies do 
    query  = 
      from cur in Currency,
      where: cur.active ==  ^true 
    Repo.all query
  end

  def list_active_currencies_paginate(params) do 
    query  = 
      from cur in Currency,
      where: cur.active ==  ^true 
    Repo.paginate(query, params)
  end

  def list_active_currencies do 
    query  = 
      from cur in Currency,
      where: cur.active ==  ^true 
    Repo.all query
  end

  def list_monetary_currency do
     query  = 
      from cur in Currency,
      where: cur.active ==  ^true 
      and cur.fee == 0.0
    Repo.all query
  end


  def get_currency_by(querable) do
    Repo.get_by(Currency, querable)
  end

  def get_currency(id), do: Repo.get(Currency, id)
  def get_currency!(id), do: Repo.get!(Currency, id)

  def create_currency(attrs \\ %{}) do
    %Currency{}
    |> Currency.changeset(attrs)
    |> Repo.insert()
  end

  def update_currency(%Currency{} = currency, attrs) do
    currency
    |> Currency.changeset(attrs)
    |> Repo.update()
  end

  def delete_currency(%Currency{} = currency) do
    Repo.delete(currency)
  end

  def insert_currencies(list) do
    Repo.insert_all(Currency, list)
  end

  def change_currency(%Currency{} = currency) do
    Currency.changeset(currency, %{})
  end

  alias GreekCoin.Funds.Treasury

  def list_treasuries_user_id(user_id) do
    from(treasury in Treasury,
      where: treasury.user_id == ^user_id)
    |> Repo.all 
    |> Repo.preload([:currency, {:user, [:credential, :address]}])
  end

  def list_treasuries() do
    Repo.all Treasury
  end
  


  def get_treasury!(id), do: Repo.get!(Treasury, id)

  def get_treasury(user_id, currency_id) do
    query  = 
      from tr in Treasury,
      where: tr.user_id ==  ^user_id 
      and tr.currency_id == ^currency_id
    Repo.one(query)
    |> Repo.preload([:currency])
  end

  def create_treasury(attrs \\ %{}) do
    %Treasury{}
    |> Treasury.changeset(attrs)
    |> Repo.insert()
  end


  def update_treasury(%Treasury{} = treasury, attrs) do
    treasury
    |> Treasury.changeset(attrs)
    |> Repo.update()
  end


  def delete_treasury(%Treasury{} = treasury) do
    Repo.delete(treasury)
  end


  def change_treasury(%Treasury{} = treasury) do
    Treasury.changeset(treasury, %{})
  end

  alias GreekCoin.Funds.RequestTransaction


  def list_request_transactions_simple do
    Repo.all(RequestTransaction)
    |> Repo.preload([:src_currency, :tgt_currency, :action])
  end

  def list_request_transactions do
    Repo.all(RequestTransaction)
    |> Repo.preload([{:user, :credential}, :src_currency, :tgt_currency, :action])
  end

  def list_user_request_transactions(id) do
   query = from re_tr in RequestTransaction,
      where: re_tr.user_id == ^id
   query 
   |> Repo.all 
   |> Repo.preload([{:user, :credential}, :src_currency, :tgt_currency])
  end


  def get_request_transaction!(id) do
    Repo.get!(RequestTransaction, id)
    |> Repo.preload([{:user, :credential}, :src_currency, :tgt_currency, :action])
  end


  def create_request_transaction(attrs \\ %{}) do
    insert_result = 
      %RequestTransaction{}
      |> RequestTransaction.changeset(attrs)
      |> Repo.insert()
    case insert_result do
      {:ok, transaction} ->
        transaction =  Repo.preload(transaction, [:src_currency, :tgt_currency, :action])
        {:ok, transaction}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def fulfil_request_transaction(%RequestTransaction{} = re_tr, %Treasury{} = src_tr, %Treasury{} = tgt_tr) do
    resut = re_tr
    |> RequestTransaction.changeset(%{status: "fulfiled"})
    |> Repo.update()

    src_tr 
    |> Treasury.changeset(%{balance: (src_tr.balance - re_tr.src_amount)})
    |> Repo.update()

    tgt_tr
    |> Treasury.changeset(%{balance: (tgt_tr.balance + (re_tr.src_amount * re_tr.exchange_rate))})
    |> Repo.update
    
    resut
  end


  def update_request_transaction(%RequestTransaction{} = request_transaction, attrs) do
    result =
      request_transaction
      |> RequestTransaction.changeset(attrs)
      |> Repo.update()
      case result do
        {:ok, transaction} ->
          {:ok, Repo.preload(transaction, [{:user, :credential}, :src_currency, :tgt_currency])}
        {:error, changeset } ->
          {:error, changeset}
      end
  end

  def cancel_user_transaction_request(%{"trans_id"=> id}) do
    get_request_transaction!(id)
    |> RequestTransaction.changeset(%{status: "user canceled"})
    |> Repo.update()
  end


  def delete_request_transaction(%RequestTransaction{} = request_transaction) do
    Repo.delete(request_transaction)
  end


  def change_request_transaction(%RequestTransaction{} = request_transaction) do
    RequestTransaction.changeset(request_transaction, %{})
  end


  alias GreekCoin.Funds.Wallet

  def list_wallets do
    Repo.all(Wallet)
    |> Repo.preload(:currency)
  end

  def get_wallet!(id) do 
    Repo.get!(Wallet, id)
    |> Repo.preload(:currency)
  end

  def list_wallets_per_user(user_id) do
    query = from wallet in Wallet,
      where: wallet.user_id == ^user_id
    query 
    |>  Repo.all
    |>  Repo.preload(:currency)
  end

  def get_wallet_by_currency_and_user(currency_id, user_id) do
   query = from wall in Wallet,
     where: wall.currency_id == ^currency_id and wall.user_id == ^user_id and wall.active == true
   query
   |> Repo.all 

  end

  def get_wallet_by_currency_id(currency_id) do
   query = from wall in Wallet,
     where: wall.currency_id == ^currency_id and is_nil(wall.user_id) and wall.active == true
   query
   |> Repo.all 
  end

  def create_wallet(attrs \\ %{}) do
    %Wallet{}
    |> Wallet.changeset(attrs)
    |> Repo.insert()
  end

  def update_wallet(%Wallet{} = wallet, attrs) do
    wallet
    |> Wallet.changeset(attrs)
    |> Repo.update()
  end


  def delete_wallet(%Wallet{} = wallet) do
    Repo.delete(wallet)
  end

  def change_wallet(%Wallet{} = wallet) do
    Wallet.changeset(wallet, %{})
  end


  # User Wallets -------------------------- 

  alias GreekCoin.Funds.UserWallet

  def list_user_wallets do
    Repo.all(UserWallet)
  end

  def create_user_wallet(attrs \\ %{}) do
    %UserWallet{}
    |> UserWallet.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_wallet(%UserWallet{} = user_wallet, attrs) do
    user_wallet
    |> UserWallet.changeset(attrs)
    |> Repo.update()
  end

  def get_user_wallet!(id), do: Repo.get!(UserWallet, id)

  def delete_user_wallet(wallet_id) do
    from(wallet in UserWallet,
      where: wallet.id == ^wallet_id)
    |> Repo.delete_all
  end

  def change_user_wallet(%UserWallet{} = user_wallet) do
    UserWallet.changeset(user_wallet, %{})
  end

  # ----------------------------------------->

  # User Bank Details --------------------------
  alias GreekCoin.Funds.UserBankDetails

  def list_user_bank_details do
    Repo.all(UserBankDetails)
  end

  def get_user_bank_details!(id), do: Repo.get!(UserBankDetails, id)

  def create_user_bank_details(attrs \\ %{}) do
    %UserBankDetails{}
    |> UserBankDetails.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_bank_details(%UserBankDetails{} = user_bank_details, attrs) do
    user_bank_details
    |> UserBankDetails.changeset(attrs)
    |> Repo.update()
  end

  def delete_user_bank_details(bank_id) do
    from(bank in UserBankDetails,
      where: bank.id == ^bank_id)
    |> Repo.delete_all
  end

  def change_user_bank_details(%UserBankDetails{} = user_bank_details) do
    UserBankDetails.changeset(user_bank_details, %{})
  end

  # ------------------------------------------------>

  # GreekCoin.Funds.Action -------------------------->
  alias GreekCoin.Funds.Action

  def get_action!(id), do: Repo.get!(Action, id)

  def create_action(attrs \\ %{}) do
    %Action{}
    |> Action.changeset(attrs)
    |> Repo.insert()
  end

  def update_action(%Action{} = action, attrs) do
    action
    |> Action.changeset(attrs)
    |> Repo.update()
  end

  def delete_action(%Action{} = action) do
    Repo.delete(action)
  end

  def change_action(%Action{} = action) do
    Action.changeset(action, %{})
  end

  # ------------------------------------------------->
  alias GreekCoin.Funds.BankDetails

  def list_bank_details_by_user(_user_id) do
      query =  BankDetails
      query
      |> Repo.all
      |> Repo.preload(:operation_account)
  end

  def list_bank_details do
    Repo.all(BankDetails)
    |> Repo.preload([:operation_account, :country])
  end

  def list_active_bank_details do
    query = from b in BankDetails, where: b.active == true
    Repo.all(query)
    |> Repo.preload([:operation_account, :country])
  end



  def get_bank_details!(id) do
    Repo.get!(BankDetails, id)
    |> Repo.preload(:country)
  end

  def create_bank_details(attrs \\ %{}) do
    %BankDetails{}
    |> BankDetails.changeset(attrs)
    |> Repo.insert()
  end

  def update_bank_details(%BankDetails{} = bank_details, attrs) do
    bank_details
    |> BankDetails.changeset(attrs)
    |> Repo.update()
  end

  def delete_bank_details(%BankDetails{} = bank_details) do
    Repo.delete(bank_details)
  end

  def change_bank_details(%BankDetails{} = bank_details) do
    BankDetails.changeset(bank_details, %{})
  end  

end
