defmodule GreekCoin.Repo.Migrations.CreateUserBankDetails do
  use Ecto.Migration

  def change do
    create table(:user_bank_details) do
      add :beneficiary_name, :string
      add :iban, :string
      add :swift_code, :string
      add :acount_no, :string
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :withdraw_id, references(:withdrawals, on_delete: :nothing)
      add :recipient_address, :string
      add :bank_address, :string

      timestamps()
    end

    create index(:user_bank_details, [:user_id])
    create index(:user_bank_details, [:withdraw_id])
  end
end
