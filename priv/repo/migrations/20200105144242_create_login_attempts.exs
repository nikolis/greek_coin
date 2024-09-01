defmodule GreekCoin.Repo.Migrations.CreateLoginAttempts do
  use Ecto.Migration

  def change do
    create table(:login_attempts) do
      add :ip_address, :string
      add :result, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:login_attempts, [:user_id])
  end
end
