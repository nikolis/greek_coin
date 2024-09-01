defmodule GreekCoin.Repo.Migrations.CreateActions do
  use Ecto.Migration

  def change do
    create table(:actions) do
      add :title, :string

      timestamps()
    end
  end
end
