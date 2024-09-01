defmodule GreekCoin.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :title, :string
      add :tag, :string
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create index(:languages, [:country_id])
  end
end
