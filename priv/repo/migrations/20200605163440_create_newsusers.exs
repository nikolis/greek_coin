defmodule GreekCoin.Repo.Migrations.CreateNewsusers do
  use Ecto.Migration

  def change do
    create table(:newsusers) do
      add :description, :text
      add :status, :string
      add :email, :string
      add :canceled, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:newsusers, [:email])
  end
end
