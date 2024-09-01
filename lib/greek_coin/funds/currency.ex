defmodule GreekCoin.Funds.Currency do
  use Ecto.Schema
  import Ecto.Changeset
  alias GreekCoin.Funds.Treasury 

  schema "currencies" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :alias, :string
    field :alias_sort, :string
    field :active, :boolean
    field :active_deposit, :boolean
    field :fee, :float
    field :deposit_fee, :float
    field :withdraw_fee, :float
    field :pic_url, :string
    field :active_withdraw, :boolean
    field :primary, :boolean
    field :decimals, :integer

    has_many :trasury, Treasury
    timestamps()
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:title, :description, :url, :alias, :active, :fee, :active_deposit, :deposit_fee, :withdraw_fee, :pic_url, :active_withdraw, :primary, :alias_sort, :decimals])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end
