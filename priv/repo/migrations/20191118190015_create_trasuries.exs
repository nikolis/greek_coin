defmodule GreekCoin.Repo.Migrations.CreateTrasuries do
  use Ecto.Migration

  def change do
    create table(:trasuries) do
      add :balance, :float
      add :user_id, references(:users, on_delete: :nothing)
      add :currency_id, references(:currencies, on_delete: :nothing)

      timestamps()
    end

    create index(:trasuries, [:currency_id, :user_id], name: :index_trasuries_on_user_currency)
  end
end
