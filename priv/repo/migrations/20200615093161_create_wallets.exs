defmodule GreekCoin.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :private_key, :string
      add :public_key, :string
      add :additional_info, :string
      add :active, :bool

      add :currency_id, references(:currencies, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      add :operation_account_id, references(:operation_accounts, on_delete: :delete_all)

      timestamps()
    end

    create index(:wallets, [:currency_id, :user_id])
    create index(:wallets, [:operation_account_id])
  end
end
