defmodule GreekCoin.Funds.UserBankDetails do
  use Ecto.Schema
  import Ecto.Changeset

  alias GreekCoin.Funds.Withdraw

  schema "user_bank_details" do
    field :acount_no, :string
    field :beneficiary_name, :string
    field :iban, :string
    field :name, :string
    field :swift_code, :string
    field :recipient_address
    field :bank_address


    field :user_id, :id

    belongs_to :withdraw, Withdraw
    
    timestamps()
  end

  @doc false
  def changeset(user_bank_details, attrs) do
    user_bank_details
    |> cast(attrs, [:beneficiary_name, :iban, :swift_code, :acount_no, :name, :withdraw_id, :recipient_address, :bank_address])
    |> validate_required([:beneficiary_name, :iban, :swift_code, :name, :recipient_address])
  end
end
