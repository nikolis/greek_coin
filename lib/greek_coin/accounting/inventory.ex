defmodule GreekCoin.Accounting.Inventory do
  use Ecto.Schema
  import Ecto.Changeset
  alias GreekCoin.Funds.Currency

  schema "inventories" do
    field :balance, :float
    field :operation_account_id, :id

    belongs_to :currency, Currency

    timestamps()
  end

  @doc false
  def changeset(inventory, attrs) do
    inventory
    |> cast(attrs, [:balance, :currency_id, :operation_account_id])
    |> validate_required([:balance, :currency_id, :operation_account_id])
    |> unique_constraint(:currency_per_account, name: :operation_currency_index)
  end
end
