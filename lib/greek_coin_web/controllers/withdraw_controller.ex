defmodule GreekCoinWeb.WithdrawController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Withdraw
  alias GreekCoin.Accounts
  alias GreekCoin.Email
  alias GreekCoin.Mailer
  import Ecto.Query
  alias GreekCoin.Repo
  alias GreekCoin.Accounting
  alias Ecto.Multi
  alias GreekCoin.Authenticator

  action_fallback GreekCoinWeb.FallbackController

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
           from withdraw in Withdraw
        "all" ->
           from withdraw in Withdraw

        "completed" ->
           from(withdraw in Withdraw,
             where: withdraw.status == "completed") 

        "pending" ->
           from(withdraw in Withdraw,
             where: withdraw.status == "email_verified") 
      end

     query = 
       if(dateS == "all" or is_nil(dateS)) do
         query
       else 
         case Date.from_iso8601(dateS) do
           {:ok , date } ->
             from withdraw in query,
             where: fragment("?::date", withdraw.updated_at) >= ^date
           {:error, _ } ->
             query
         end
       end

     query = 
       if(toDateS == "all" or is_nil(dateS)) do
         query
       else 
         case Date.from_iso8601(toDateS) do
           {:ok , date } ->
             from withdraw in query,
             where: fragment("?::date", withdraw.updated_at) <= ^date
           {:error, _ } ->
             query
         end
       end

    {withdraw, kerosene} = Repo.paginate(query,params)
    withdraw = Repo.preload(withdraw, [:currency, :user_wallet, :user_bank_details])
    render(conn, "list.json", withdraw: withdraw, kerosene: kerosene)

  end

  def index_user(conn, _params) do
    user_auth = Guardian.Plug.current_resource(conn)
    withdrawals = Funds.list_withdrawals_per_user(user_auth.id)
    render(conn, "index.json", withdrawals: withdrawals)
  end 

  def find_withdraw_plossibility(currency_id, user_id, par_ammount) do
    if(is_nil(currency_id)) do
       {:Err, "Currency not recognized"}
    else
        currency = GreekCoin.Funds.get_currency(currency_id)
        if(is_nil(currency)) do
          {:Err, "Currency not recognized"}

        else
            if (par_ammount ) < 0 do
              {:Err, "You cannot initiate a withdraw with negative ammount"}
            else
              if((par_ammount - currency.withdraw_fee) > 0 )do

                  treasury = Funds.get_treasury(user_id, currency_id)
                  withdraws = Funds.list_withdrawals_per_user_currency(user_id, currency_id)
                  withdraws = Enum.filter(withdraws, fn x -> (x.status != "completed") end)
                  ammount = List.foldr(withdraws, 0, fn x, acc -> acc + x.ammount end) 
                  if(is_nil(treasury)) do
                     {:Err, "Not enough funds for another withdrawall"}
                  else
                     case (ammount + par_ammount ) >= treasury.balance do
                       true ->
                         {:Err, "Not enough funds for another withdrawall"}
                       false ->
                         {:Ok , "Proceed"}
                     end
                  end
              else
                 {:Err, "The Withdraw fee is higher than the ammount"}
              end
            end
        end
    end
  end


  def create(conn, %{"withdraw" => withdraw_params}) do
    user_auth = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_auth.id)
    if(user.clearance_level >= 1) do
      case find_withdraw_plossibility(Map.get(withdraw_params, "currency_id"),user.id,Map.get(withdraw_params, "ammount")) do
        {:Err, message} ->
             conn
              |> put_status(:forbidden)
              |> json(%{"error"=> message})
        {:Ok, _useless} ->
          case user.auth2fa do
            false ->
              withdraw_params = Map.put(withdraw_params, "user_id", user_auth.id)
              withdraw_params = Map.put(withdraw_params, "status", "created")
              with {:ok, %Withdraw{} = withdraw} <- Funds.create_withdraw(withdraw_params) do
                withdraw = Repo.preload(withdraw, [:currency, :user_wallet, :user_bank_details])
                if Mix.env != :test do
                  token = GreekCoin.Token.generate_new_withdraw_token(withdraw)
                  verification_url = withdraw_url(token)
                  verification_email = Email.withdraw_verification_email(user, verification_url, withdraw)
                  _mail_sent = Mailer.deliver_now verification_email
                end
            
                conn
                |> put_status(:created)
                |> put_resp_header("location", Routes.withdraw_path(conn, :show, withdraw))
                |> render("show2fa.json", withdraw: withdraw)
              end
           true ->
              withdraw_params = Map.put(withdraw_params, "user_id", user_auth.id)
              withdraw_params = Map.put(withdraw_params, "status", "2fa needed")
              with {:ok, %Withdraw{} = withdraw} <- Funds.create_withdraw(withdraw_params) do
                withdraw = Repo.preload(withdraw, [:currency, :user_wallet, :user_bank_details])
                token = GreekCoin.Token.generate_new_withdraw_token(withdraw)
                conn
                |> put_status(:created)
                |> put_resp_header("location", Routes.withdraw_path(conn, :show, withdraw))
                |> json(%{"token" => token, "withdraw" => nil}) 
               end
          end
      end
    else
        conn
        |> put_status(:forbidden)
        |> json(%{"error"=> "To proceed with this action your account must be complient with kyc rules"})
    end
  end

  def verify_withdraw2fa(conn, %{"withdraw_token" => token, "token" => fa_token}) do
    result  = GreekCoin.Token.verify_withdraw_request_token(token)
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)
    case result do
      {:ok, deposit_id} ->
        withdraw = GreekCoin.Funds.get_withdraw!(deposit_id)
        case Authenticator.validate_token(user.credential.ga_secret, fa_token) do
          {:ok, :pass} ->
            marked = GreekCoin.Funds.update_withdraw(withdraw, %{"status" => "created"})
            case marked do
              {:ok, withdraw} ->
                token = GreekCoin.Token.generate_new_withdraw_token(withdraw)
                verification_url = withdraw_url(token)
                verification_email = Email.withdraw_verification_email(user, verification_url, withdraw)
                _mail_sent = Mailer.deliver_now verification_email

                conn
                |> put_status(:ok)
                |> render("show2fa.json", withdraw: withdraw)
                
              {:error, _error} ->
                conn
                |> put_status(:unauthorized)
                |> json("Something went wrong with your request")
            end
          {:error, :invalid_token } ->
            conn
            |> put_status(:unauthorized)
            |> json("Google 2fa token was not verified")
        end
      {:error, _err} ->
        conn
        |> put_status(:unauthorized)
        |> json("Invalid token")
    end
  end


  def withdraw_url(token) do
    GreekCoinWeb.Endpoint.url <> "/verification?type=vwithdraw&parameter="<>token
  end

  def verify_withdraw(conn, %{"token" => token}) do
    result  = GreekCoin.Token.verify_withdraw_request_token(token)
    case result do
      {:ok, deposit_id} ->
        withdraw = GreekCoin.Funds.get_withdraw!(deposit_id) 
        if(withdraw.status == "2fa needed") do
           conn
           |> put_status(:unauthorized)
           |> json("Could not verify through an email a withdraw that failed 2fa verification")
        else
            marked = GreekCoin.Funds.mark_withdrawall_as_email_verified(withdraw)
            case marked do
              {:ok, withdraw} ->
                conn
                |> json("Marked as verified")
              {:error, _error} ->
                conn
                |> put_status(:unauthorized)
                |> json("Could not authorize the withdraw please contact admins")
            end
        end
      {:error, _err} ->
        conn
        |> put_status(:unauthorized)
        |> json("Invalid token")
    end
  end


  def show(conn, %{"id" => id}) do
    withdraw = Funds.get_withdraw!(id)
    render(conn, "show.json", withdraw: withdraw)
  end


  defp find_operation_account_viability(operationAccount , withdraw) do
    filtered = Enum.filter operationAccount.inventories, fn inv -> (withdraw.currency_id == inv.currency_id) and (withdraw.ammount <= inv.balance) end
    if(Enum.empty?(filtered)) do
      {:error, "There are not enough funds in the account"}
    else 
      [head | _tail] = filtered
      {:ok, head}
    end
  end

  def update(conn, %{"id" => id, "withdraw" => withdraw_params}) do
    withdraw = Funds.get_withdraw!(id)

    with {:ok, %Withdraw{} = withdraw} <- Funds.update_withdraw(withdraw, withdraw_params) do
      render(conn, "show.json", withdraw: withdraw)
    end
  end

  def delete(conn, %{"id" => id}) do
    withdraw = Funds.get_withdraw!(id)
    if withdraw.status == "created" do
      if !is_nil(withdraw.user_wallet) do
         Funds.delete_user_wallet(withdraw.user_wallet.id)
      end
      if !is_nil(withdraw.user_bank_details) do
         Funds.delete_user_bank_details(withdraw.user_bank_details.id) 
      end
      with {:ok, %Withdraw{}} <- Funds.delete_withdraw(withdraw) do
        put_status(conn, :ok)
        render(conn, "withdraw.json", %{withdraw: withdraw})
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json("Entity is already proccessed")
    end
  end
end
