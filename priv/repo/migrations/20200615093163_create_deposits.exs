defmodule GreekCoin.Repo.Migrations.CreateDeposits do
  use Ecto.Migration

  def change do
    create table(:deposits) do
      add :status, :string
      add :ammount, :float
      add :alias, :string
      add :comment, :string
      add :fee, :float

      add :user_id, references(:users, on_delete: :nothing)
      add :currency_id, references(:currencies, on_delete: :nothing)
      add :bank_details_id, references(:bank_details, on_delete: :nothing)
      add :wallet_id, references(:wallets, on_delete: :nothing)

      timestamps()
    end

    create index(:deposits, [:user_id])
    create index(:deposits, [:currency_id])
    create index(:deposits, [:alias])
  end
end
