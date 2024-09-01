defmodule GreekCoin.Repo.Migrations.CreateOperationAccounts do
  use Ecto.Migration

  def change do
    create table(:operation_accounts) do
      add :url, :string
      add :title, :string
      add :description, :text
      add :src, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:operation_accounts, [:user_id])
    create unique_index(:operation_accounts, [:title])
  end
end
