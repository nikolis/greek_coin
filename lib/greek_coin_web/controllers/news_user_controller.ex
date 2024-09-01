defmodule GreekCoinWeb.NewsUserController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Newsletter
  alias GreekCoin.Newsletter.NewsUser

  action_fallback GreekCoinWeb.FallbackController

  def index(conn, _params) do
    newsusers = Newsletter.list_newsusers()
    render(conn, "index.json", newsusers: newsusers)
  end

  def create(conn, %{"news_user" => news_user_params}) do
    user = Newsletter.get_news_user_by_email(news_user_params["email"])
    if(is_nil(user)) do
        news_user_params = Map.put(news_user_params, "status", "created")
        with {:ok, %NewsUser{} = news_user} <- Newsletter.create_news_user(news_user_params) do
          #token = GreekCoin.Token.generate_new_newsletter_token(news_user)
          #verification_url = newsletter_url(token)
          #verification_email = GreekCoin.Email.newsletter_verification_email(news_user, verification_url)
                
          #_mail_sent = GreekCoin.Mailer.deliver_now verification_email

          conn
          |> put_status(:created)
          |> render("show.json", news_user: news_user)
        end
    else
       marked = Newsletter.update_news_user(user, %{"status" => "created"})
       case marked do
         {:ok, _user} ->
           json(conn, "Successfully Registered")
         {:error, _error} ->
           conn
           |> put_status(:unauthorized)
           |> json("Invalid token")
       end
     end
  end


  def delete(conn, %{"email" => email}) do

    # token = GreekCoin.Token.generate_new_newsletter_token_for_delete(email)
    #  verification_url = newsletter_url(token)
    #verification_email = GreekCoin.Email.newsletter_delete_verification_email(email, verification_url)
            
    #   _mail_sent = GreekCoin.Mailer.deliver_now verification_email
          user = Newsletter.get_news_user_by_email(email)
            marked = Newsletter.update_news_user(user, %{"status" => "deleted"})
            case marked do
              {:ok, _user} ->
                json(conn, "Successfully deregistered")
              {:error, _error} ->
                conn
                |> put_status(:unauthorized)
                |> json("Invalid email")
            end

  end

  def newsletter_url(token) do
    GreekCoinWeb.Endpoint.url <> "/verification?type=dnewsletterv&parameter="<>token
  end

  def verify_news_letter_email_delete(conn, %{"token" => token}) do
    result  = GreekCoin.Token.verify_newsletter_user_token_for_delete(token)
    case result do
      {:ok, newsUserEmail} ->
        user = Newsletter.get_news_user_by_email(newsUserEmail)
            marked = Newsletter.update_news_user(user, %{"status" => "deleted"})
            case marked do
              {:ok, _user} ->
                json(conn, "Successfully deregistered")
              {:error, _error} ->
                conn
                |> put_status(:unauthorized)
                |> json("Invalid token")
            end
      {:error, err} ->
        conn
        |> put_status(:unauthorized)
        |> json("Invalid token")
    end
  end




  def verify_news_letter_email(conn, %{"token" => token}) do
    result  = GreekCoin.Token.verify_newsletter_user_token(token)
    case result do
      {:ok, newsUserID} ->
        user = Newsletter.get_news_user!(newsUserID)
        case user.status do
          "verified" ->
            conn
            |> put_status(:unauthorized)
            |> json("Already registered") 
          _ ->
            marked = Newsletter.update_news_user(user, %{"status" => "verified"})
            case marked do
              {:ok, _user} ->
                json(conn, "Congratulations")
              {:error, _error} ->
                conn
                |> put_status(:unauthorized)
                |> json("Invalid token")
            end
        end
      {:error, err} ->
        conn
        |> put_status(:unauthorized)
        |> json("Invalid token")
    end
  end

  def show(conn, %{"id" => id}) do
    news_user = Newsletter.get_news_user!(id)
    render(conn, "show.json", news_user: news_user)
  end

  def update(conn, %{"id" => id, "news_user" => news_user_params}) do
    news_user = Newsletter.get_news_user!(id)

    with {:ok, %NewsUser{} = news_user} <- Newsletter.update_news_user(news_user, news_user_params) do
      render(conn, "show.json", news_user: news_user)
    end
  end

  def delete(conn, %{"id" => id}) do
    news_user = Newsletter.get_news_user!(id)

    with {:ok, %NewsUser{}} <- Newsletter.delete_news_user(news_user) do
      send_resp(conn, :no_content, "")
    end
  end
end
