defmodule GreekCoinWeb.Router do
  use GreekCoinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug GreekCoinWeb.Auth
    plug Auth.SlidingSessionTimeout, timeout_after_seconds: (60 * 60 *2)   # <=

    plug CORSPlug, origin: ["http://localhost:4000"]
  end

  pipeline :jwt_authenticated do
    plug GreekCoin.Guardian.AuthPipeline
  end

  pipeline :admin_auth do
    plug GreekCoin.Guardian.AdminAuthPipeline
  end


  scope "/api/v1", GreekCoinWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]
    put "/user/reset/password/email", UserController, :reset_password_email
    put "/user/set/password/email", UserController, :set_password
    resources "/newsletter/users", NewsUserController 
    resources "/users/login", AuthController, only: [:create, :delete]
    post "/user/2fa/login/validate", AuthController, :validate_login_token
  end

  scope "/verify", GreekCoinWeb do
    pipe_through :browser


    # get "/email/:token", UserController, :verify_email
    # get "/withdrawall/:token", WithdrawController, :verify_withdraw
    #get "/newsletter/:token", NewsUserController, :verify_withdraw

  end

  scope "/api/v1/", GreekCoinWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/user/resend/vermail", UserController, :resent_verification_email
    get "/user/2fa/create", AuthController, :get_2fa_immage
    post "/user/2fa/activate", AuthController, :activate_2fa
    post "/user/2fa/deactivate", AuthController, :deactivate_2fa
    post "/user/2fa/validate", AuthController, :validate_token
    post "/users/immage", UserController, :upload_user_immage
    post "/users/immage/view", UserController, :get_url_immage
    #post "/users/immage/old", UserController, :upload_user_immage23

    get "/users/login/attempts", LoginAttemptController, :index
    put "/user/reset/password", UserController, :reset_password
    put "/users", UserController, :update 
    get "/self", UserController, :get_user
    resources "/wallet", WalletController, only: [:create, :update, :delete, :show]
    get "/provided/wallet", WalletController, :list_user_wallet
    get "/wallet/:mode/:currency_id", WalletController, :index
    resources "/bank", BankDetailsController
    resources "/country", CountryController
    get "/users/available/banks", BankDetailsController, :client_index

  end


  scope "/api/v1/transaction", GreekCoinWeb do
    pipe_through [:api, :jwt_authenticated]

    post "/sellbuy", RequestTransactionController, :sell_create
    post "/verify", RequestTransactionController, :verify_request
  end

  scope "/api/v1/transaction", GreekCoinWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/funds/", FundController, :get_user_balance 
    get "/exchange", FundController, :exchange 
    resources "/transactions", RequestTransactionController, only: [:create, :delete, :show]
    get "/transactions/:mode/:date/:toDate", RequestTransactionController, :index
    put "/transactions", RequestTransactionController, :cancel_transaction
    get "/user/transactions/:currency_id/:action/:date/:toDate", RequestTransactionController, :get_user_transaction 
    resources "/deposit", DepositController, [:create, :delete]
    get "/treasury", TreasuryController, :index
    get "/deposit/:mode/:date/:toDate", DepositController, :index
    get "/withdraw/:mode/:date/:toDate", WithdrawController, :index

    get "/user/deposit", DepositController, :list_user_deposits
    resources "/withdraw", WithdrawController, only: [:create, :delete, :show]
    get "/user/withdraw", WithdrawController, :index_user   
  end


  scope "/admin/api/v1", GreekCoinWeb do 
    pipe_through [:api, :admin_auth]
    
    put "/user/update/:user_id", UserController, :admin_update
    get "/user/:id", UserController, :show 
    put "/deposit", DepositController, :pay_deposit
    put "/withdraw", WithdrawController, :mark_withdraw_paid
    put "/withdraw/cancel", WithdrawController, :cancel_withdraw
    put "/deposit/cancel", DepositController, :cancel_deposit

    get "/users/:mode", UserController, :index
    get "/kraken_update", KrakenController, :update_currencies_from_kraken
    put "/kraken_update", KrakenController, :update_currency 
  end  
  
  scope "/kraken" , GreekCoinWeb do    
    get "/currencies/:nature", KrakenController, :get_active_currencies
    get "/monetary", KrakenController, :deposit_monetary_currency
    get "/assetpairs", KrakenController, :get_asset_pairs 
    get "/krakenpairs", KrakenController, :get_kraken_pairs
    get "/krakenpairs/raw", KrakenController, :get_kraken_pairs_raw
    get "/combinations", KrakenController, :get_pairs
    get "/amazon", KrakenController, :get_immages_from_amazon
    get "/actions", ActionController, :index
  end


  scope "/verify", GreekCoinWeb do
    pipe_through [:api, :jwt_authenticated]
    post "/withdrawall/2fa", WithdrawController, :verify_withdraw2fa

  end

  scope "/verify", GreekCoinWeb do
    pipe_through :api

    get "/newsletter/:token", NewsUserController, :verify_news_letter_email
    get "/email/:token", UserController, :verify_email
    get "/withdrawall/:token", WithdrawController, :verify_withdraw
    get "/deregisternews/:token", NewsUserController, :verify_news_letter_email_delete
  end

  scope "/deregister", GreekCoinWeb do
     get "/newsletter/:email", NewsUserController, :delete
  end

  scope "/*path", GreekCoinWeb do  
    pipe_through :browser      
      
    get "/", ServingController, :main_page
  end


end
