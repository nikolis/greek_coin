defmodule GreekCoin.Funds.Action do
  use Ecto.Schema
  import Ecto.Changeset

  schema "actions" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(action, attrs) do
    action
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
