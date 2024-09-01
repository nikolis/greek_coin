defmodule GreekCoinWeb.NewsUserView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.NewsUserView

  def render("index.json", %{newsusers: newsusers}) do
    %{data: render_many(newsusers, NewsUserView, "news_user.json")}
  end

  def render("show.json", %{news_user: news_user}) do
    %{data: render_one(news_user, NewsUserView, "news_user.json")}
  end

  def render("news_user.json", %{news_user: news_user}) do
    %{id: news_user.id,
      description: news_user.description,
      status: news_user.status,
      email: news_user.email,
      canceled: news_user.canceled}
  end
end
