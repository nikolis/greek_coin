defmodule GreekCoin.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :country, :string
      add :title, :string
      add :city, :string
      add :zip, :string
      add :user_id, references(:users, on_delete: :nothing, on_replce: :nothing)

      timestamps()
    end

    create index(:addresses, [:user_id])
  end
end
