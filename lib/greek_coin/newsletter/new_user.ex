defmodule GreekCoin.Newsletter.NewUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "newsusers" do
    field :canceled, :boolean, default: false
    field :description, :string
    field :email, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(new_user, attrs) do
    new_user
    |> cast(attrs, [:description, :status, :email, :canceled])
    |> validate_required([:description, :status, :email, :canceled])
  end
end
