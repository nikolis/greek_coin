defmodule GreekCoinWeb.AdminView do 
  use GreekCoinWeb, :view
  alias GreekCoinWeb.RequestTransactionView

  def render("insufficient_funds.json", %{trans_id: id}) do
    %{
      error: ["The funds of the user are not enough to persue this transaction"]
    }
  end

  def render("already_foolfilled.json", %{trans_id: id}) do
    %{
      error: ["The transaction is already completed"]
    }
  end


  def render("transaction_completed.json", %{transaction: transaction}) do
      RequestTransactionView.render("request_transaction.json", %{request_transaction: transaction})
  end

  def render("error.json", %{changeset: changeset}) do
    ret =  Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    ret
  end 

end
