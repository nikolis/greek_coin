defmodule GreekCoin.Repo.Migrations.CreateUserWallets do
  use Ecto.Migration

  def change do
    create table(:user_wallets) do
      add :bublic_key, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :withdraw_id, references(:withdrawals, on_delete: :nothing)

      timestamps()
    end

    create index(:user_wallets, [:user_id])
    create index(:user_wallets, [:withdraw_id])
  end
end
