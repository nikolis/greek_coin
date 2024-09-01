defmodule GreekCoin.Funds.RequestTransaction do
  use Ecto.Schema
  import Ecto.Changeset
   
  alias GreekCoin.Funds.Currency
  alias GreekCoin.Accounts.User
  alias GreekCoin.Funds.Action
  alias GreekCoin.Accounting.OperationAccount

  schema "request_transactions" do
    field :exchange_rate, :float
    field :src_amount, :float
    field :status, :string
    field :fee, :float
    field :end_cost, :float
    field :comment, :string
    field :comment_cancel, :string

    belongs_to :user, User
    belongs_to :src_currency, Currency
    belongs_to :tgt_currency, Currency
    belongs_to :action, Action
    belongs_to :operation_account, OperationAccount
   
    timestamps()
  end

  @doc false
  def changeset(request_transaction, attrs) do
    request_transaction
    |> cast(attrs, [:status, :src_amount, :exchange_rate, :src_currency_id, :tgt_currency_id, :user_id, :action_id, :fee, :end_cost, :operation_account_id, :comment, :comment_cancel])
    |> validate_required([:status, :src_amount, :exchange_rate])
  end
end
