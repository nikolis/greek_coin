defmodule GreekCoin.Repo.Migrations.CreateInventories do
  use Ecto.Migration

  def change do
    create table(:inventories) do
      add :balance, :float
      add :operation_account_id, references(:operation_accounts, on_delete: :nothing)
      add :currency_id, references(:currencies, on_delete: :nothing)

      timestamps()
    end

    create index(:inventories, [:operation_account_id])
    create index(:inventories, [:currency_id])

    create unique_index(:inventories, [:currency_id, :operation_account_id],
             name: :operation_currency_index
           )
  end
end
