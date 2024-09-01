defmodule GreekCoinWeb.AuthView do
  use GreekCoinWeb, :view

  def render("jwt.json", %{jwt: jwt, user: user}) do
    %{ user: %{
      token: jwt,
      username: user.credential.email,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.credential.email,
      image: "example/images.com" 
      },
      login_token: nil
    }
  end

  def render("auth_error.json", %{email: email}) do
    %{
      error: "email password combination not correct"
    }
  end

  def render("captcha_error.json", %{msg: msg}) do
    %{
      error: "captcha not verified"
    }
  end


end
