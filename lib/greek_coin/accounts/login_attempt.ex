defmodule GreekCoin.Accounts.LoginAttempt do
  use Ecto.Schema
  import Ecto.Changeset

  alias GreekCoin.Accounts.User

  schema "login_attempts" do
    field :ip_address, :string
    field :result, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(login_attempt, attrs) do
    login_attempt
    |> cast(attrs, [:ip_address, :result, :user_id])
    |> validate_required([:ip_address, :result])
  end
end
