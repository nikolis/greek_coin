defmodule GreekCoin.Funds.Treasury do
  use Ecto.Schema
  import Ecto.Changeset
  alias GreekCoin.Funds.Currency 
  alias GreekCoin.Accounts.User

  schema "trasuries" do
    field :balance, :float

    belongs_to :user, User
    belongs_to :currency, Currency

    timestamps()
  end

  @doc false
  def changeset(treasury, attrs) do
    treasury
    |> cast(attrs, [:balance, :user_id, :currency_id])
    |> unique_constraint(:user_currency_constraint, name: :index_trasuries_on_user_currency)
    |> validate_required([:balance, :user_id, :currency_id])
  end
end
