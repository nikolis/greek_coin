defmodule GreekCoin.Funds.UserWallet do
  use Ecto.Schema
  import Ecto.Changeset

  alias GreekCoin.Funds.Withdraw

  schema "user_wallets" do
    field :bublic_key, :string

    field :user_id, :id

    belongs_to :withdraw, Withdraw
 
    timestamps()
  end

  @doc false
  def changeset(user_wallet, attrs) do
    user_wallet
    |> cast(attrs, [:bublic_key, :withdraw_id])
    |> validate_required([:bublic_key])
  end
end
