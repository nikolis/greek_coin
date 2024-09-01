defmodule GreekCoin.Repo do
  use Ecto.Repo,
    otp_app: :greek_coin,
    adapter: Ecto.Adapters.Postgres
  use Kerosene, per_page: 10
end
