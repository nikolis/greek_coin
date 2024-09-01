# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :greek_coin,
  ecto_repos: [GreekCoin.Repo],
  default_locale: "gr", locales: ~w(gr en)


# Configures the endpoint
config :greek_coin, GreekCoinWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  otp_app: :greek_coin,
  url: [host: "localhost"],
  secret_key_base: "jqpYr3U9d5zLmFl77SMoF4NSzonTv233WO372IydUwT2K3tOU5+Y53Oruz8rssvI",
  render_errors: [view: GreekCoinWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GreekCoin.PubSub, adapter: Phoenix.PubSub.PG2],
  f2a_secret: "CAVSTE7ODUTY3SN5"



config :greek_coin, GreekCoin.Guardian,
       issuer: "greek_coin",      
       secret_key: "PX6QqC/CIc6jt7ZrNhHBtU5TUFetBHSP6DRd4QLB0q3cPdVxfuRhBp6rjeQhBz/b",
       permissions: %{
         default: [
           :read_token,
           :revoke_token
         ],
         verified_user: [
           :read_token,
           :revoke_token,
           :ask_access
         ],
         kyc_complient: [
           :read_token,
           :revoke_token,
           :ask_access,
           :transaction
         ],
         admin_user: [
           :read_token,
           :revoke_token,
           :ask_access,
           :admin
         ]
       }


config :greek_coin, GreekCoin.AuthPipeline,
  module: GreekCoin.Guardian,
  error_handler: GreekCoinWeb.AuthErrorHandler


#Config google recaptcha
config :greek_coin,
  google_recaptcha:  [ 
    secret_key: "6LcFecIUAAAAAPwj99yaRWHXz2HWXV30NdyNFevh"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason


config :greek_coin, GreekCoin.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "email-smtp.eu-west-1.amazonaws.com",
  hostname: "localhost",
  port: 25,
  username: "AKIA4Z4GRTRXG6PLD4TB", # or {:system, "SMTP_USERNAME"}
  password: "BCGVCNXmuUKOWDggWoJHmkypZFmBoHGfNJcPyvLjCGAu", # or {:system, "SMTP_PASSWORD"}
  tls: :if_available, # can be `:always` or `:never`
  #allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  ssl: false, # can be `true`
  retries: 1,
  no_mx_lookups: false, # can be `true`
  auth: :if_available # can be `always`. If your smtp relay requires authentication set it to `alway


config :s3_direct_upload,
  aws_access_key: "AKIA4Z4GRTRXJ73CBUXC",
  aws_secret_key: "JA45Jd9XsfwB/9tG3wgL25w0EQqJnF5irHiAXy36",
  aws_s3_bucket: "greek.coin.user.images",
  aws_region: "eu-central-1"


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
