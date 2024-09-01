defmodule GreekCoin.Repo.Migrations.CreateRequestTransactions do
  use Ecto.Migration

  def change do
    create table(:request_transactions) do
      add :status, :string
      add :src_amount, :float
      add :exchange_rate, :float
      add :fee, :float
      add :end_cost, :float
      add :comment, :string
      add :comment_cancel, :string

      add :action_id, references(:actions, on_delte: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :src_currency_id, references(:currencies, on_delete: :nothing)
      add :tgt_currency_id, references(:currencies, on_delete: :nothing)
      add :operation_account_id, references(:operation_accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:request_transactions, [:user_id])
    create index(:request_transactions, [:src_currency_id])
    create index(:request_transactions, [:tgt_currency_id])
    create index(:request_transactions, [:operation_account_id])
  end
end
