defmodule GreekCoin.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user_name, :string
      add :first_name, :string
      add :last_name, :string
      add :status, :string
      add :profile_pic_url, :string
      add :role, :string
      add :mobile, :string
      add :auth2fa, :bool
      add :clearance_level, :int

      add :id_pic_front, :string
      add :id_pic_front_comment, :string
      add :id_pic_back, :string
      add :id_pic_back_comment, :string
      add :ofi_bill_file, :string
      add :ofi_bill_file_comment, :string
      add :selfie_pic, :string
      add :selfie_pic_comment, :string

      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:users, [:user_name])
  end
end
