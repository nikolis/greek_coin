defmodule GreekCoinWeb.RequestTransactionController do
  use GreekCoinWeb, :controller  

  alias GreekCoin.Funds
  alias GreekCoin.Funds.RequestTransaction
  alias GreekCoin.Accounts
  alias GreekCoin.Repo
  import Ecto.Query
  alias GreekCoinWeb.TransactionsChannel 
  @request_verification_salt "request verification salt"
  alias GreekCoin.Mailer


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

  plug :authenticate when action in [:sell_create, :create]


  def get_user_transaction(conn, params) do
    id = Map.get(params, "currency_id")
    action = Map.get(params, "action")
    dateS = Map.get(params, "date")
    toDateS = Map.get(params, "toDate")
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)
    query = from transaction in RequestTransaction,
      where: transaction.user_id == ^user.id
    query = 
      if (action == "all") do
        query
      else 
        case Integer.parse(action) do
          {id_num, _rest} ->
            from transaction in query,
            where: transaction.action_id == ^id_num

          :error ->
            query
        end
      end

    query = 
      if(id == "all") do
        query 
      else 
        case  Integer.parse(id) do
          {id_num, _rest} ->
            from transaction in query,
            where: transaction.tgt_currency_id == ^id_num
          :error ->
            query
        end
      end
     
     query = 
       if(dateS == "all") do
         query
       else 
         case Date.from_iso8601(dateS) do
           {:ok , date } ->
             from transaction in query,
             where: fragment("?::date", transaction.inserted_at) >= ^date
           {:error, _ } ->
             query
         end
       end

     query = 
       if(toDateS == "all") do
         query
       else 
         case Date.from_iso8601(toDateS) do
           {:ok , date } ->
             from transaction in query,
             where: fragment("?::date", transaction.inserted_at) <= ^date
           {:error, _ } ->
             query
         end
       end

    {transactions, kerosene} = Repo.paginate(query, params)
    transactions = Repo.preload(transactions, [:src_currency, :tgt_currency, :action, {:user, :credential}])
    render(conn, "list.json", transactions: transactions, kerosene: kerosene)
  end


  def get_user_transaction2(conn, params) do
    id = Map.get(params, "currency_id")
    action = Map.get(params, "action")
    dateS = Map.get(params, "date")
    dateResult = Date.from_iso8601(dateS)
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)
    query = 
      if(id == "all") do
        if(action == "all") do
          from transaction in RequestTransaction,
          where: transaction.user_id == ^user.id
        else
          {id_num, _who} = Integer.parse(action)
          from transaction in RequestTransaction,
          where: transaction.user_id == ^user.id
          and transaction.action_id == ^id_num 
        end
    else
      if (action == "all") do
        {id_num, _who} = Integer.parse(id)
        from transaction in RequestTransaction,
        where: transaction.user_id == ^user.id 
        and transaction.tgt_currency_id == ^id_num
      else
        {id_num, _who} = Integer.parse(id)
        {id_num_action, _who2} = Integer.parse(action)
        from transaction in RequestTransaction,
        where: transaction.user_id == ^user.id 
        and transaction.tgt_currency_id == ^id_num
        and transaction.action_id == ^id_num_action
      end
    end
    {transactions, kerosene} = Repo.paginate(query, params)
    transactions = Repo.preload(transactions, [:src_currency, :tgt_currency, :action, {:user, :credential}])
    render(conn, "list.json", transactions: transactions, kerosene: kerosene)
  end

  def get_kraken_pairs_raw(pair, action) do
        {:ok, %HTTPoison.Response{body: body}} = 
          asset_pair_query_url(pair)
          |> HTTPoison.post("",[{"Content-Type", "application\json"}])
        dec_body = 
          body
          |> Poison.decode!
        %{"error"=> _errors, "result"=> result} = dec_body
        {numb, _left} =  
           if(action.title == "Buy") do 
              Float.parse(List.first (Map.get(Map.get(result, pair), "a")))
           else
              Float.parse(List.first (Map.get(Map.get(result, pair), "b")))
           end
        numb
  end 

  def asset_pair_query_url(pair) do
    URI.to_string(%URI{
      scheme: "https",
      host: "api.kraken.com",  
      path: "/0/public/Ticker?pair=" <> pair
      })
  end

  def generate_new_request_token(%RequestTransaction{id: trans_id}) do
    Phoenix.Token.sign(GreekCoinWeb.Endpoint, @request_verification_salt, trans_id)
  end

  def verify_difference(rate, rate_par) do
    case rate > rate_par do
      false ->
        false 
      true ->
        false
    end
  end

  def verify_new_request_token(token) do
    Phoenix.Token.verify(GreekCoinWeb.Endpoint, @request_verification_salt, token, max_age: 60)
  end

  def verify_request(conn, %{"token" => token}) do
    result = verify_new_request_token(token)
    case result do
      {:ok, request_id} ->
        request = Funds.get_request_transaction!(request_id)
        success = Funds.update_request_transaction(request, %{"status" => "Created"})
        case success do
          {:ok, request} ->
            GreekCoinWeb.Endpoint.broadcast!("transactions:0", "new_transaction", %{"new_transaction" => "created"})
            mail = GreekCoin.Email.new_transaction_notification()
            if Mix.env != :test do
               Mailer.deliver_now mail 
            end
            conn
            |> put_status(:created)
            |> render("request_transaction_ver.json", %{request_transaction: request, status: 2, token: ""})

          {:err, error} ->
            conn
            |> put_status(:bad_request)
            |> json(%{"error" => error })
        end
      {_,_} ->
        conn
        |> put_status(:forbiden)
        |> json(%{"error" => "Invalid token"})
    end
  end



  def clearance_validator({_, _}, %GreekCoin.Accounts.User{} = user) do
    if(user.clearance_level < 1) do
      {:error, :clearance_level}
    else
      {:ok, user}
    end
  end

  def funds_validator(prequel, tr_params) do
    case prequel do
      {:ok, user} ->
        case Funds.validate_transaction(user, tr_params) do
          {:error, _} ->
            {:error, :funds_validator}
          {:ok, param} ->
            {:ok, param}
        end
      {:error, error} ->
        {:error, error}
    end
  end

  def values_validator(prequel, tr_params) do
     case prequel do
       {:ok, _} ->
         case tr_params["src_amount"] do
           nil ->
             {:error, :bad_values}
           ammount ->
                 case ammount <= 0 do
                   true ->
                     {:error, :bad_values}
                   false ->
                     {:ok, tr_params}
                 end
         end
       {:error, reason} ->
          {:error, reason}
     end
  end

  def verification_validator(prequel, tr_params, user_res, action) do
    case prequel do
      {:error, reason} ->
        {:error, reason}
      {:ok, params} ->
        pair = Map.get(tr_params, "pair")
        exchange_rate_par = Map.get(tr_params, "exchange_rate")
        exchange_rate = get_kraken_pairs_raw(pair, action)
        verification = verify_difference(exchange_rate, exchange_rate_par)
        params = 
          if (verification) do
            tr_params = Map.put(tr_params, "status", "Created")
            tr_params = Map.put(tr_params, "user_id", user_res.id)
            tr_params
          else
            tr_params = Map.put(tr_params, "status", "Verification required")
            tr_params = Map.put(tr_params, "user_id", user_res.id)
            tr_params = Map.put(tr_params, "exchange_rate", exchange_rate)
            tr_params
          end
        {:ok, params} 
    end
  end

  def sell_create(conn, %{"request_transaction" => tr_params}) do
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)
    pair = Map.get(tr_params, "pair")
    action = Funds.get_action!(Map.get(tr_params, "action_id"))
    exchange_rate_par = Map.get(tr_params, "exchange_rate")
    exchange_rate = get_kraken_pairs_raw(pair, action)
    verification = verify_difference(exchange_rate, exchange_rate_par)
    validation = 
      {:ok, :ok}
        |> clearance_validator(user)
        |> funds_validator(tr_params)
        |> values_validator(tr_params)
        |> verification_validator(tr_params, user_res, action)
    case validation do
      {:ok, params} ->
        case Funds.create_request_transaction(params) do
          {:ok, %RequestTransaction{} = request_transaction} ->
            if(verification) do
               conn
               |> put_status(:created)
               |> render("request_transaction_ver.json", %{request_transaction: request_transaction, status: 2, token: ""})
            else
              conn
              |> put_status(:accepted)
              |> render("request_transaction_ver.json", %{request_transaction: request_transaction, status: 1, token: generate_new_request_token(request_transaction)})
            end
        end
      {:error, reason} ->
        case reason do
          :bad_values ->
            conn
            |> put_status(:bad_request)
            |> json("The values you have provided are not working")
          :funds_validator ->
            conn
            |> put_status(:bad_request)
            |> json("You do not have enough funds")
          :clearance_level ->
            conn
            |> put_status(:bad_request)
            |> json("You are not complient with KYC rules")
        end
    end
  end

  
  def create(conn, %{"request_transaction" => tr_params}) do
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)
    tr_params = Map.put(tr_params, "user_id", user_res.id)
    tr_src_currency = Map.get(tr_params, "src_currency")
    tr_tgt_currency = Map.get(tr_params, "tgt_currency")

    if(is_nil(tr_src_currency) or is_nil (tr_src_currency)) do
      json(conn, "Not all need informations are provided")
    else 

      src_currency = Funds.get_currency_by(%{title: tr_src_currency})
      tgt_currency = Funds.get_currency_by(%{title: tr_tgt_currency})

      case user.status do
        "kyc_complient" ->
          if(is_nil(src_currency) or is_nil(tgt_currency)) do
            conn
            |> put_status(:bad_request)
            |> render("pair_error.json", %{src: tr_src_currency, tgt: tr_tgt_currency})
          else 
            tr_params = Map.put(tr_params, "src_currency_id", src_currency.id)
            tr_params = Map.put(tr_params, "tgt_currency_id", tgt_currency.id)
            tr_params = Map.put(tr_params, "status", "created")
            with {:ok, %RequestTransaction{} = request_transaction} <- Funds.create_request_transaction(tr_params) do
              TransactionsChannel.handle_broadcast()
              conn
              |> put_status(:created)
              |> put_resp_header("location", Routes.request_transaction_path(conn, :show, request_transaction))
              |> render("show.json", request_transaction: request_transaction)
            end
          end
        "email_verfified" ->
          conn
          |> put_status(:unauthorized)
          |> render("kyc_failure.json", user: user)
        _ ->
          conn
          |> put_status(:unauthorized)
          |> render("email_verification.json", user: user)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    request_transaction = Funds.get_request_transaction!(id)
    render(conn, "show.json", request_transaction: request_transaction)
  end

end
