defmodule GreekCoin.Repo.Migrations.CreateAccountTransaction do
  use Ecto.Migration

  def change do
    create table(:operation_account_transactions) do
      add :comment, :string
      add :amount, :float
      add :fee, :float
      add :type, :string

      add :currency_id, references(:currencies, on_delete: :nothing)

      add :operation_account_src_id, references(:operation_accounts, on_delete: :nothing)
      add :operation_account_tgt_id, references(:operation_accounts, on_delete: :nothing)
      timestamps()
    end

    create index(:operation_account_transactions, [:operation_account_src_id])
  end

end
