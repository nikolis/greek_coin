defmodule GreekCoinWeb.NewUserView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.NewUserView

  def render("index.json", %{newsusers: newsusers}) do
    %{data: render_many(newsusers, NewUserView, "new_user.json")}
  end

  def render("show.json", %{new_user: new_user}) do
    %{data: render_one(new_user, NewUserView, "new_user.json")}
  end

  def render("new_user.json", %{new_user: new_user}) do
    %{id: new_user.id,
      description: new_user.description,
      status: new_user.status,
      email: new_user.email,
      canceled: new_user.canceled}
  end
end
