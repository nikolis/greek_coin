defmodule GreekCoin.Token do

  alias GreekCoin.Accounts.User
  alias GreekCoin.Funds.Withdraw
  alias GreekCoin.Newsletter.NewsUser

  @account_verification_salt "account verification salt"
  @withdraw_verification_salt "withdraw_virification_salt"
  @newsletter_verification_salt "newsletter_verification_salt"

  @login_salt "login_salt"

  def verify_new_account_email_token(token) do
    max_age = 86400
    Phoenix.Token.verify(GreekCoinWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end

  def generate_new_account_email_token(email) do
    Phoenix.Token.sign(GreekCoinWeb.Endpoint, @account_verification_salt, email)
  end

  def generate_new_withdraw_token(%Withdraw{id: withdraw_id}) do
    Phoenix.Token.sign(GreekCoinWeb.Endpoint, @withdraw_verification_salt, withdraw_id)
  end

  def verify_withdraw_request_token(token) do
    max_age = 86400
    Phoenix.Token.verify(GreekCoinWeb.Endpoint, @withdraw_verification_salt, token, max_age: max_age)
  end

  def generate_new_newsletter_token_for_delete(email) do
    Phoenix.Token.sign(GreekCoinWeb.Endpoint, @newsletter_verification_salt, email)
    end

  def verify_newsletter_user_token_for_delete(token) do
    max_age = 86400
    Phoenix.Token.verify(GreekCoinWeb.Endpoint, @newsletter_verification_salt, token, max_age: max_age)
  end

  def generate_new_newsletter_token(%NewsUser{id: news_user_id}) do
    Phoenix.Token.sign(GreekCoinWeb.Endpoint, @newsletter_verification_salt, news_user_id)
    end

  def verify_newsletter_user_token(token) do
    max_age = 86400
    Phoenix.Token.verify(GreekCoinWeb.Endpoint, @newsletter_verification_salt, token, max_age: max_age)
  end

  def generate_login_token(%User{id: user_id}) do
    Phoenix.Token.sign(GreekCoinWeb.Endpoint, @login_salt, user_id)
  end

  def validate_login_token(token) do
    max_age = 60
    Phoenix.Token.verify(GreekCoinWeb.Endpoint, @login_salt, token, max_age: max_age)
  end


end
