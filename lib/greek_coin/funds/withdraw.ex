defmodule GreekCoin.Funds.Withdraw do
  use Ecto.Schema
  import Ecto.Changeset

  alias GreekCoin.Funds.UserBankDetails
  alias GreekCoin.Funds.UserWallet
  alias GreekCoin.Funds.Currency
  alias GreekCoin.Accounts.User
  


  schema "withdrawals" do
    field :ammount, :float
    field :status, :string
    field :comment, :string

    belongs_to :user, User
    belongs_to :currency, Currency

    has_one :user_bank_details, UserBankDetails, on_replace: :delete
    has_one :user_wallet, UserWallet, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(withdraw, attrs) do
    withdraw
    |> cast(attrs, [:ammount, :user_id, :currency_id, :status, :comment])
    |> validate_required([:ammount])
    |> cast_assoc(:user_bank_details, with: &UserBankDetails.changeset/2, required: false, on_replace: :update)
    |> cast_assoc(:user_wallet, with: &UserWallet.changeset/2, required: false, on_replace: :update)
  end
end
