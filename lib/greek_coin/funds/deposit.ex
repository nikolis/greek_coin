defmodule GreekCoin.Funds.Deposit do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias GreekCoin.Accounts.User
  alias GreekCoin.Funds.Currency
  alias GreekCoin.Funds.BankDetails
  alias GreekCoin.Funds.Wallet

  schema "deposits" do
    field :ammount, :float
    field :status, :string
    field :alias, :string
    field :comment, :string

    belongs_to :user, User
    belongs_to :currency, Currency
    belongs_to :wallet, Wallet
    belongs_to :bank_details, BankDetails

    timestamps()
  end

  def changeset(deposit, attrs) do
    deposit
      |> cast(attrs, [:status, :ammount, :currency_id, :user_id, :alias, :comment])
      |> validate_required([:status, :currency_id, :user_id])
  end

  @doc false
  def changeset_monetary(deposit, attrs) do
    deposit
    |> cast(attrs, [:status, :ammount, :currency_id, :user_id, :alias, :wallet_id, :bank_details_id, :comment])
    |> validate_required([:status, :currency_id, :user_id, :bank_details_id])
    #|> validate_required_inclusion([:wallet_id, :bank_details_id])
  end

  def changeset_crypto(deposit, attrs) do
    deposit
    |> cast(attrs, [:status, :ammount, :currency_id, :user_id, :alias, :wallet_id, :bank_details_id, :comment])
    |> validate_required([:status, :currency_id, :user_id, :wallet_id])
    #|> validate_required_inclusion([:wallet_id, :bank_details_id])
  end

  def validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, &present?(changeset, &1)) do
      changeset
    else
      # Add the error to the first field only since Ecto requires a field name for each error.
      add_error(changeset, hd(fields), "One of these fields must be present: #{inspect fields}")
    end
  end

  def present?(changeset, field) do
    value = get_field(changeset, field)
    value && value != ""
  end

end
