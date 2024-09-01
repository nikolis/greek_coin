defmodule GreekCoin.Repo.Migrations.CreateBankDetails do
  use Ecto.Migration

  def change do
    create table(:bank_details) do
      add :name, :string
      add :acount_no, :string
      add :swift_code, :string
      add :iban, :string
      add :beneficiary_name, :string
      add :active, :bool
      add :bank_address, :string
      add :recipient_address, :string
      add :country_id, references(:countries, on_delete: :nothing)
      add :operation_account_id, references(:operation_accounts, on_delete: :delete_all)

      timestamps()
    end

    create index(:bank_details, [:country_id])
    create index(:bank_details, [:operation_account_id])
    create unique_index(:bank_details, [:iban])
    create unique_index(:bank_details, [:acount_no])
  end
end
