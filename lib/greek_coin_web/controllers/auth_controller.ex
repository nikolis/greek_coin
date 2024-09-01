defmodule GreekCoinWeb.AuthController do
  use GreekCoinWeb, :controller
  alias GreekCoin.Guardian
  alias GreekCoin.Accounts
  alias GreekCoin.Authenticator
  alias GreekCoin.Token

  @secret_key Application.get_env(:greek_coin, :google_recaptcha)[:secret_key]
  action_fallback GreekCoinWeb.FallbackController


  def verify(token) do
    if Mix.env == :test do
      :ok
    else
      _params = 
      %{
        "secret" => @secret_key,
        "response"=> token,
        "Content-Type" => "application/json"
      }
      |> Poison.encode!
      body = Poison.encode!(%{})
      _headers = [{"Content-type", "application/json"}]
  
      respo = HTTPoison.post(process_url(@secret_key, token), body)
      case respo do
        {:ok, response} ->
          {:ok, str_res} = Jason.decode(response.body)
          %{"success" => suc} =  str_res
           case suc do
             false ->
               :err
             true ->
               :ok
            end      
        {:error, error_resp } ->
          :err
      end
    end
  end
"""
  def verify(token) do
    :ok
  end
"""
  def process_url(secret, token) do
    URI.to_string(%URI{
      scheme: "https",
      host: "www.google.com",  
      path: "/recaptcha/api/siteverify",
      query: "secret=#{secret}&response=#{token}"
      })
  end

  def create(conn, %{"credential" => %{"email" => email, "password" => pass, "captcha_token" => google_token}}) do
    IO.puts("loginnnnnnnnnnnn")
    capt = verify(google_token)
    case capt do
      :err ->
        conn
        |> render("captcha_error.json", %{msg: ""})
      :ok -> 
        case GreekCoin.Accounts.authenticate_by_email_and_pass(email, pass) do
          {:ok, user} ->
            case user.auth2fa do
              false ->
                 with {:ok, jwt, _claim} <- Guardian.encode_and_sign(user, %{role: user.role}) do
                  ip_add = 
                    conn.remote_ip
                    |> :inet_parse.ntoa
                    |> to_string()
                    Accounts.create_login_attempt(%{user_id: user.id, result: "Success", ip_address: ip_add})
                    conn
                    |> GreekCoinWeb.Auth.login(user)
                    |> render("jwt.json", %{jwt: jwt, user: user})
                 end

              true ->
                token = Token.generate_login_token(user)
                conn
                |> json(%{"login_token" => token, "user" => nil})
            end
          {:error, _reason} ->
            ip_add = 
               conn.remote_ip
               |> :inet_parse.ntoa
               |> to_string()
            if !is_nil(Accounts.get_user_by_email(email)) do
              Accounts.create_failed_login_attempt(email, ip_add)
            end
            conn
            |> put_status(:unauthorized)
            |> json(%{errors: %{credentials: ["Email password combination was not correct!"]}})
        end
    end
  end

  def get_2fa_immage(conn, _what) do
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)
    secret = NioGoogleAuthenticator.generate_secret
    case Accounts.update_credential_light(user.credential, %{"ga_secret" => secret}) do
      {:ok, _cred} ->
        json(conn, Authenticator.generate_image_url(secret))
      {:error, changeset} ->
        json(conn, changeset)
    end
  end

  def deactivate_2fa(conn, %{"validation_code" => code}) do
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)
        case Accounts.update_user(user, %{"auth2fa" => false}) do
          {:ok, _user} ->
            json(conn, "2fa deactivated(Google authenticator)")
          {:error, error} ->
            json(conn, error)
        end
  end

  def activate_2fa(conn, %{"validation_code" => code}) do
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res.id)
    case Authenticator.validate_token(user.credential.ga_secret, code) do
      {:ok, :pass} ->
        case Accounts.update_user(user, %{"auth2fa" => true}) do
          {:ok, _user} ->
            json(conn, "2fa activated(Google authenticator)")
          {:error, error} ->
            json(conn, error)
        end
      {:error, :invalid_token} ->
         conn
         |> put_status(:unauthorized)
         |> json("Invalid 2fa token")
    end
  end

  def validate_login_token(conn, %{"token" => token, "login_token" => login_token}) do
    case Token.validate_login_token(login_token) do
      {:ok, user_id} ->
        user = Accounts.get_user!(user_id)
        case Authenticator.validate_token(user.credential.ga_secret, token) do
          {:ok, :pass} ->
             with {:ok, jwt, _claim} <- Guardian.encode_and_sign(user, %{role: user.role}) do
                  ip_add = 
                    conn.remote_ip
                    |> :inet_parse.ntoa
                    |> to_string()
               Accounts.create_login_attempt(%{user_id: user.id, result: "Success", ip_address: ip_add})
               conn
               |> GreekCoinWeb.Auth.login(user)
               |> render("jwt.json", %{jwt: jwt, user: user})
             end
          {:error, :invalid_token} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{errors: %{"Please insert" => ["your 2FA code"]}})
        end
      {:error, error} ->
        json(conn, %{errors: %{"login token" => "token was not valid"}})
    end 
  end


  def validate_token(conn, %{"token" => token}) do
    user_res = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_res)

    case Authenticator.validate_token(user.credential.ga_secret, token) do
      {:ok, :pass} ->
        json(conn,"Verified")
      {:error, :invalid_token} ->
        conn
        |> put_status(:unauthorized)
        |> json("Invalid token")
    end
  end

end
