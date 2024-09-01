defmodule GreekCoin.Accounting.OperationAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias GreekCoin.Accounting.Inventory

  schema "operation_accounts" do
    field :description, :string
    field :src, :string
    field :title, :string
    field :url, :string
    field :user_id, :id

    has_many :inventories, Inventory

    timestamps()
  end

  @doc false
  def changeset(operation_acccount, attrs) do
    operation_acccount
    |> cast(attrs, [:url, :title, :description, :src])
    |> validate_required([:title])
  end
end
