defmodule GreekCoinWeb.RequestTransactionView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.RequestTransactionView
  import Kerosene.JSON
  alias GreekCoinWeb.CurrencyView

  def render("list.json", %{transactions: transactions, kerosene: kerosene, conn: conn}) do
    %{data: render_many(transactions, RequestTransactionView, "request_transaction.json"),
      pagination: paginate(conn, kerosene)
    }
  end

  def render("index.json", %{request_transactions: request_transactions}) do
    result = %{data: render_many(request_transactions, RequestTransactionView, "request_transaction_ver.json")}
    result
  end

  def render("show.json", %{request_transaction: request_transaction}) do
    %{data: render_one(request_transaction, RequestTransactionView, "request_transaction.json")}
  end

  def render("shows_simple.json", %{request_transaction: request_transaction}) do
    %{data: render_one(request_transaction, RequestTransactionView, "request_transaction_simple.json")}
  end

  def render("request_transaction_ver.json", %{request_transaction: request_transaction, status: status, token: token}) do
    %{
      status: status,
      token: token,
      transaction: %{
        id: request_transaction.id,
        status: request_transaction.status,
        src_amount: request_transaction.src_amount,
        exchange_rate: request_transaction.exchange_rate,
        src_currency: render_one(request_transaction.src_currency, CurrencyView, "currency.json"),
        tgt_currency: render_one(request_transaction.tgt_currency, CurrencyView, "currency.json"),
        update_at: request_transaction.updated_at,
        end_cost: request_transaction.end_cost,
        comment: request_transaction.comment,
        action_id: request_transaction.action_id,
      }
    }
  end

  def render("request_transaction.json", %{request_transaction: request_transaction}) do
     %{
        id: request_transaction.id,
        status: request_transaction.status,
        src_amount: request_transaction.src_amount,
        exchange_rate: request_transaction.exchange_rate,
        src_currency: render_one(request_transaction.src_currency, CurrencyView, "currency.json"),
        tgt_currency: render_one(request_transaction.tgt_currency, CurrencyView, "currency.json"),
        update_at: request_transaction.updated_at,
        created_at: request_transaction.inserted_at,
        end_cost: request_transaction.end_cost,
        comment: request_transaction.comment,
        action_id: request_transaction.action_id,
        user_account: request_transaction.user.credential.email 

      }

  end

  def render("request_transaction_simple.json", %{request_transaction: request_transaction}) do
    %{id: request_transaction.id,
      status: request_transaction.status,
      src_amount: request_transaction.src_amount,
      exchange_rate: request_transaction.exchange_rate,
      user: request_transaction.user_id,
      src_currency: request_transaction.src_currency_id,
      tgt_currency: request_transaction.tgt_currency_id,    
      end_cost: request_transaction.end_cost,
      comment: request_transaction.comment
    }
  end


  def render("kyc_failure.json", %{user: user} ) do
    %{
      user_email: user.credential.email,
      problem: "You don't have provided all informations needed from the kyc rules
      please follow instruction to provide all necessery personal information"
    }
  end

  def render("email_verification.json", %{user: user}) do
    %{
      user_email: user.credential.email,
      problem: "Your account is not verified please verify your email, hint: if you missed the email we sent you visit your profiles page to re initiate the process"
    }
  end


end
