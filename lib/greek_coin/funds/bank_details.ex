defmodule GreekCoin.Funds.BankDetails do
  use Ecto.Schema
  import Ecto.Changeset

  alias GreekCoin.Localization.Country
  alias GreekCoin.Accounting.OperationAccount

  schema "bank_details" do
    field :acount_no, :string
    field :beneficiary_name, :string
    field :iban, :string
    field :name, :string
    field :swift_code, :string
    field :active, :boolean, default: false
    field :recipient_address
    field :bank_address

    belongs_to :country, Country
    belongs_to :operation_account, OperationAccount
    timestamps()
  end

  @doc false
  def changeset(bank_details, attrs) do
    bank_details
    |> cast(attrs, [:name, :acount_no, :swift_code, :iban, :beneficiary_name, :country_id, :operation_account_id, :active, :bank_address, :recipient_address])
    |> unique_constraint(:iban)
    |> unique_constraint(:acount_no)
    |> validate_required([:acount_no, :iban, :beneficiary_name, :operation_account_id, :name, :swift_code])
  end
end
