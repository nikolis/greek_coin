defmodule GreekCoinWeb.LanguageView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.LanguageView

  def render("index.json", %{languages: languages}) do
    %{data: render_many(languages, LanguageView, "language.json")}
  end

  def render("show.json", %{language: language}) do
    %{data: render_one(language, LanguageView, "language.json")}
  end

  def render("language.json", %{language: language}) do
    %{id: language.id,
      title: language.title,
      tag: language.tag}
  end
end
