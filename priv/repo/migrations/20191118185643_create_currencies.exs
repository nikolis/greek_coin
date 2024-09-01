defmodule GreekCoin.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :title, :string
      add :description, :text
      add :url, :string
      add :alias, :string
      add :alias_sort, :string
      add :active, :bool
      add :active_deposit, :bool
      add :active_withdraw, :bool
      add :fee, :float
      add :deposit_fee, :float
      add :withdraw_fee, :float
      add :pic_url, :string
      add :primary, :bool
      add :decimals, :int
      add :order, :int, default: 0
      add :value, :float, default: 0.0

      timestamps()
    end
  end
end
