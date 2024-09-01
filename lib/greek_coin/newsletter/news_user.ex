defmodule GreekCoin.Newsletter.NewsUser do
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
  def changeset(news_user, attrs) do
    news_user
    |> cast(attrs, [:description, :status, :email, :canceled])
    |> unique_constraint(:email)
    |> validate_required([:status, :email])
  end
end
