defmodule GreekCoin.Repo.Migrations.CreateWithdrawals do
  use Ecto.Migration

  def change do
    create table(:withdrawals) do
      add :ammount, :float
      add :customer_fee, :float
      add :internal_fee, :float
      add :status, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :currency_id, references(:currencies, on_delete: :nothing)
      add :comment, :string

      timestamps()
    end

    create index(:withdrawals, [:user_id])
    create index(:withdrawals, [:currency_id])
  end
end
