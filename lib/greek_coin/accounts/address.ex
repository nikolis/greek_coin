defmodule GreekCoin.Accounts.Address do
  use Ecto.Schema
  
  import Ecto.Changeset
  alias GreekCoin.Accounts.User

  schema "addresses" do
    field :city, :string
    field :country, :string
    field :title, :string
    field :zip, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:country, :title, :city, :zip])
    |> validate_required([:country, :title, :city, :zip])
  end
end
