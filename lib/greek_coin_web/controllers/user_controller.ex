defmodule GreekCoinWeb.UserController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Accounts
  alias GreekCoin.Accounts.User 
  alias GreekCoin.Email
  alias GreekCoin.Mailer
  alias GreekCoin.Security
  import Ecto.Query
  alias GreekCoin.Repo



  action_fallback GreekCoinWeb.FallbackController

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
       conn
    else
      conn
        |> put_status(:unauthorized)
        |> json(%{"error" => "Please login to complete action"})
        |> halt()
    end
  end

  plug :authenticate when action in [:reset_password, :update, :upload_user_immage]

  def index(conn, params) do
    mode = Map.get(params, "mode")
    query = 
      case mode do 
        "all" ->
          from user in User

        "email_verified" ->
           from(user in User,
             where: user.status == "email_verified")

        "kyc_complient" ->
          from(user in User,
            where: user.status == "kyc_complient")

        "created" ->
          from(user in User,
            where: user.status == "created")

        "admin_susspended" ->
          from(user in User,
            where: user.status == "admin_susspended")

      end
    {users, kerosene} = Repo.paginate(query,params)
    users = Repo.preload(users, [:credential, :address])
    render(conn, "list.json", users: users, kerosene: kerosene)
  end


  def get_user(conn, _) do
    user_auth = Guardian.Plug.current_resource(conn)
    _claims = Guardian.Plug.current_claims(conn)
    user = Accounts.get_user!(user_auth.id)
    conn
    |> render("user_detailed.json", user: user)
  end


  def show(conn, %{"id" => user_id}) do
    #user_auth = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_id)
    conn
    |> render("user_detailed.json", user: user)
  end

  def admin_update(conn, %{"user" => user_params, "user_id" => user_id}) do
    user = Accounts.get_user!(user_id) 
    
    case Accounts.admin_user_update(user, user_params) do
      {:ok, user} ->
        conn
        |> render("user.json", user: user)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", changeset: changeset)
    end  

  end


  def update(conn, %{"user" => user_params}) do
    user_auth = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_auth.id)
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> render("show.json", user: user)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", changeset: changeset)
    end  
  end

  def reset_password_email(conn, %{"email"=> email}) do
    user = Accounts.get_user_by_email(email)
    case is_nil(user) do
      true ->
        conn
        |> put_status(:unauthorized)
        |> json("Email not in database")
      false ->
        token = GreekCoin.Token.generate_new_account_email_token(user.credential.email)
        verification_email = Email.credential_reset_email(user, token)
        _mail_sent = Mailer.deliver_now verification_email
        conn 
        |> json("An email with a token has been send to you, use the token to update password")
    end
  end

  def set_password(conn, %{"token" => token, "credential" => credentials}) do
    result  = GreekCoin.Token.verify_new_account_email_token(token)
    case result do
      {:ok, email} ->
        user = Accounts.get_user_by_email(email)
        case Accounts.reset_user_password(user.credential,  credentials) do
           {:ok, _user} ->
             json(conn,  "Password has been updated")
           {:error,  %Ecto.Changeset{} = changeset} ->
             conn
             |> put_status(:unprocessable_entity)
             |> render(GreekCoinWeb.ErrorView, "error.json", changeset: changeset)
        end
      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json("Invalid token!")
    end
  end

  def reset_password(conn, %{"credential" => credentials, "password" => password}) do
    user_auth = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_auth.id)
    case GreekCoin.Accounts.authenticate_by_email_and_pass(user.credential.email, password) do
      {:ok, user} ->
         case Accounts.reset_user_password(user.credential,  credentials) do
           {:ok, _user} ->
             json(conn,  "Password has been updated")
           {:error,  %Ecto.Changeset{} = changeset} ->
             conn
             |> put_status(:unprocessable_entity)
             |> render(GreekCoinWeb.ErrorView, "error.json", changeset: changeset)
         end
      {:error, _reason} ->
        json(conn, "old password was not correct")
    end
  end


  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, _user} -> 
          if Mix.env != :test do
            token = GreekCoin.Token.generate_new_account_email_token(user_params["credential"]["email"])
            verification_url = user_url(token)
            verification_email = Email.email_verification_email(user_params["credential"]["email"], verification_url)

            mail_sent = 
              try do 
                Mailer.deliver_now(verification_email, response: true)
              catch
                _, _ -> {%{},{:error, "Not send"}}
              end
            case mail_sent do
              {_, {:ok, _}} ->
                  conn
                  |> put_status(:created)
                  |> json("Success a verification email has beed send to your email address for please follow the link in the email to activate your account!")
              {_, {_, _}} ->
                conn
                 |> put_status(:bad_request)
                 |> json("Email account unreachable")
            end
          else
              conn
              |> put_status(:created)
              |> json("Success a verification email has beed send to your email address for please follow the link in the email to activate your account!")
          end


      {:error, %Ecto.Changeset{} = changeset} ->
         conn
         |> put_status(:bad_request)
         |> render("error.json", changeset: changeset)
    end
  end

  def resent_verification_email(conn, _params) do
    user_auth = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(user_auth.id)
    token = GreekCoin.Token.generate_new_account_email_token(user.credential.email)
    verification_url = user_url(token)
    verification_email = Email.email_verification_email(user.credential.email, verification_url)
    mail_sent = Mailer.deliver_now(verification_email, response: true)
    case mail_sent do
      {_, {:ok, _}} ->
        conn
        |> put_status(:created)
        |> json("Success a verification email has beed send to your email address for please follow the link in the email to activate your account!")

      {_, {_, _}} ->
        conn
        |> put_status(:bad_request)
        |> json("Email could not be send")
    end
  end
 
  def verify_email(conn, %{"token" => token}) do
    result  = GreekCoin.Token.verify_new_account_email_token(token)
    case result do
      {:ok, user_id} ->
        user = GreekCoin.Accounts.get_user_by_email(user_id)
        marked = GreekCoin.Accounts.mark_as_email_verified(user)
        case marked do
          {:ok, _user} ->
            json(conn, "Congratulations you have successfully verified your account")
          {:error, _error} ->
            conn
            |> put_status(:unauthorized)
            |> json("Could not verify your account please site admins")
        end
      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json("Invalid token please try again")
    end
  end

  def upload_user_immage(conn, %{ "file_hash" => file_hash, "path" => path}) do
    upload_object = Security.get_authorization_header_upload(path, file_hash)
    json(conn, upload_object)
  end


  def get_url_immage(conn, %{"path" => path}) do
    url = Security.get_image_presigned_uri(path)
    the_ret = %{url: url}
    json(conn, the_ret)
  end


  def upload_user_immage23(conn, %{"file_name" => file_name, "mimetype" => mime_type, "path" => path}) do
    upload_object = 
      %S3DirectUpload{file_name: file_name, mimetype: mime_type, path: path}
      |> S3DirectUpload.presigned
    json(conn, upload_object)
  end

  def user_url(token) do
    GreekCoinWeb.Endpoint.url <> "/verification?type=vemail&parameter="<>token
  end

end
