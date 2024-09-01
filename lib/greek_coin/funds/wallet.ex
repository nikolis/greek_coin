defmodule GreekCoin.Funds.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  alias GreekCoin.Funds.Currency 
  alias GreekCoin.Accounts.User

  alias GreekCoin.Accounting.OperationAccount

  schema "wallets" do
    field :additional_info, :string
    field :private_key, :string
    field :public_key, :string
    field :active, :boolean, default: false


    belongs_to :user, User
    belongs_to :currency, Currency
    belongs_to :operation_account, OperationAccount

    timestamps()
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:private_key, :public_key, :additional_info, :currency_id, :user_id, :operation_account_id, :active])
    |> validate_required([:currency_id, :public_key, :operation_account_id])
  end
end
