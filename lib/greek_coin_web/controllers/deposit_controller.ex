defmodule GreekCoinWeb.DepositController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Deposit
  alias GreekCoin.Accounts
  alias GreekCoin.Repo
  alias Ecto.Multi

  import Ecto.Query

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
       conn
    else
      conn
        |> put_status(:unauthorized)
        |> json(%{"error" => "Please login to complete action"})
        |> halt()
    end
  end

  plug :authenticate when action in [:create]

  def index(conn, params) do
    mode = Map.get(params, "mode")
    dateS = Map.get(params, "date")
    toDateS = Map.get(params, "toDate")

    query = 
      case mode do 
        nil ->
           from deposit in Deposit

        "all" ->
           from deposit in Deposit

        "completed" ->
           from(deposit in Deposit,
             where: deposit.status == "completed") 

        "pending" ->
           from(deposit in Deposit,
             where: deposit.status == "created") 
      end

     query = 
       if(dateS == "all" or is_nil(dateS)) do
         query
       else 
         case Date.from_iso8601(dateS) do
           {:ok , date } ->
             from deposit in query,
             where: fragment("?::date", deposit.updated_at) >= ^date
           {:error, _ } ->
             query
         end
       end

     query = 
       if(toDateS == "all" or is_nil(toDateS)) do
         query
       else 
         case Date.from_iso8601(toDateS) do
           {:ok , date } ->
             from deposit in query,
             where: fragment("?::date", deposit.updated_at) <= ^date
           {:error, _ } ->
             query
         end
       end

    {deposits, kerosene} = Repo.paginate(query,params)
    deposits = Repo.preload(deposits, [:currency, :wallet, :bank_details])
    render(conn, "list.json", deposits: deposits, kerosene: kerosene)
  end

  def list_user_deposits(conn, _params) do
    user_res = Guardian.Plug.current_resource(conn)
    deposits = Funds.list_user_deposits(user_res.id)
    render(conn, "list_simple.json", deposits: deposits)
  end



  defp clearance_validator({_, _}, %GreekCoin.Accounts.User{} = user) do
    if(user.clearance_level < 1) do
      {:error, :clearance_level}
    else
      {:ok, user}
    end
  end

  defp too_many_deposit_validator(prequel, tr_params) do
    case prequel do
      {:ok, user} ->
        count = Funds.count_user_deposits(user.id)
        if(count > 0) do
          {:error, :to_many_deposits}
        else
          {:ok, user}
        end
      {:error, error} ->
        {:error, error}
    end
  end
  
  defp currency_validator(prequel, tr_params) do
    case prequel do
      {:ok, user} ->
        if is_nil(tr_params["currency_id"]) do
          {:error, :currency_needed}
        else
          currency = Funds.get_currency(tr_params["currency_id"])
          if is_nil(currency) do
            {:error, :currency_needed}
          else
            if String.contains?(currency.title, "EUR") do
              if(currency.active_deposit) do
                 case Funds.create_deposit_monetary(tr_params, user.credential.email) do
                    {:ok, deposit} ->
                       deposit = Repo.preload(deposit, [:wallet, :bank_details])
                       {:created, deposit}
                     {:error, %Ecto.Changeset{} = changeset} ->
                       {:error, changeset}
                 end
              else
                  {:error, :currency_inactive}
              end
            else
                 {:ok, {currency, user}}
            end
          end
        end
      {:error, error} ->
        {:error, error}
    end
  end

  defp wallet_validator(prequel, tr_params) do
    case prequel do
      {:ok, {currency, user}} ->
        if(currency.active_deposit) do
           result  = get_handle_wallet(currency.id, user.id)
            case result do  
              {:err, mst} ->
                {:error, :no_wallet}
              {:ok, wallet} ->
                params = Map.put(tr_params, "wallet_id", wallet.id)
                case Funds.create_deposit_crypto(params, "") do
                  {:ok, deposit} ->
                    {:created, deposit}
                  {:err, %Ecto.Changeset{} = changeset} ->
                    {:error, changeset}
                 end
            end
        else
           {:error, :currency_inactive}
        end
      {:created, deposit} ->
        {:created, deposit}
      {:error, error} ->
        {:error, error}
    end

  end

  def create(conn, %{"deposit" => deposit_params}) do
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)

    params = Map.put(deposit_params, "status", "created")
    params = Map.put(params, "user_id", user.id)
    result = 
      {:ok, :ok}
      |> clearance_validator(user)
      |> too_many_deposit_validator(params)
      |> currency_validator(params)
      |> wallet_validator(params)
    case result do
      {:created, deposit} ->
         conn
         |> put_status(:created)
         |> render("show.json", %{deposit: deposit})

      {:error, %Ecto.Changeset{} = changeset} ->
         conn
         |> put_status(:bad_request)
         |> render("error.json", %{changeset: changeset})

      {:error, error} ->
        case error do
          :no_wallet ->
            conn
            |> put_status(:forbidden)
            |> json(%{error: "There is no available wallet"})

          :clearance_level ->
            conn
            |> put_status(:forbidden)
            |> json(%{error: "your accountis is not complient with kyc rules"})
          :to_many_deposits ->
            conn
            |> put_status(:forbidden)
            |> json(%{error: "You have too many pending deposits"})
          :currency_needed ->
            conn
            |> put_status(:forbidden)
            |> json(%{error: "A currency is needed"})
          :currency_inactive ->
            conn
            |> put_status(:forbidden)
            |> json(%{error: "The currency is not avaiable for this action"})
        end
    end

  end


  defp get_handle_wallet(currency_id, user_id) do
    walletF = Funds.get_wallet_by_currency_and_user(currency_id, user_id)
    if(is_nil(List.first(walletF))) do
      wallet = Funds.get_wallet_by_currency_id(currency_id)
      if(is_nil(List.first(wallet))) do
        {:err, "No wallet available !"}
      else
        Funds.update_wallet(List.first(wallet), %{"user_id" => user_id})
      end
    else
      {:ok, List.first(walletF)}
    end
  end

  defp handle_wallet_deposit(deposit,wallet, treasury) do
    wallet = Repo.preload(wallet, operation_account: [inventories: :currency])
    inventory = Enum.find(wallet.operation_account.inventories, fn x -> deposit.currency == x.currency end)
    if(is_nil(inventory)) do
      {:error, "Could not find matching currencies between account inventories and deposit"}
      Multi.new()
      |> Multi.insert(:inventory, GreekCoin.Accounting.Inventory.changeset(%GreekCoin.Accounting.Inventory{},%{"balance" => deposit.ammount, "currency_id" => deposit.currency_id, "operation_account_id" => wallet.operation_account.id}))
      |> Multi.update(:deposit, Funds.Deposit.changeset(deposit, %{"status" => "completed"}))
      |> Multi.update(:treasury, Funds.Treasury.changeset(treasury, %{"balance" => (treasury.balance+ deposit.ammount)}))
      |> Repo.transaction
    else
      Multi.new()
      |> Multi.update(:inventory, GreekCoin.Accounting.Inventory.changeset(inventory, %{"balance" => (inventory.balance+deposit.ammount)}))
      |> Multi.update(:deposit, Funds.Deposit.changeset(deposit, %{"status" => "completed"}))
      |> Multi.update(:treasury, Funds.Treasury.changeset(treasury, %{"balance" => (treasury.balance+ deposit.ammount)}))
      |> Repo.transaction
    end
  end



  def update(conn, %{"id" => id, "deposit" => deposit_params}) do
    deposit = Funds.get_deposit!(id)

    case Funds.update_deposit(deposit, deposit_params) do
      {:ok, deposit} ->
        conn
        |> put_flash(:info, "Deposit updated successfully.")
        |> redirect(to: Routes.deposit_path(conn, :show, deposit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", deposit: deposit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    deposit = Funds.get_deposit!(id)
    if deposit.status == "created" do
      {:ok, deposit} = Funds.delete_deposit(deposit)
      conn
      |> put_status(:ok)
      |> render("deposit.json", %{deposit: deposit})
    else
      conn
      |> put_status(:unauthorized)
      |> json("This Deposit is already proccessed") 
    end
  end
end
