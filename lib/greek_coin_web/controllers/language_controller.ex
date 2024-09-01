"""
defmodule GreekCoinWeb.LanguageController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Localization
  alias GreekCoin.Localization.Language
  action_fallback GreekCoinWeb.FallbackController

  def index(conn, _params) do
    languages = Localization.list_languages()
    render(conn, "index.json", languages: languages)
  end

  def create(conn, %{"language" => language_params}) do
    with {:ok, %Language{} = language} <- Localization.create_language(language_params) do
      conn
      |> put_status(:created)
      |> render("show.json", language: language)
    end
  end

  def show(conn, %{"id" => id}) do
    language = Localization.get_language!(id)
    render(conn, "show.json", language: language)
  end

  def update(conn, %{"id" => id, "language" => language_params}) do
    language = Localization.get_language!(id)

    with {:ok, %Language{} = language} <- Localization.update_language(language, language_params) do
      render(conn, "show.json", language: language)
    end
  end

  def delete(conn, %{"id" => id}) do
    language = Localization.get_language!(id)

    with {:ok, %Language{}} <- Localization.delete_language(language) do
      send_resp(conn, :no_content, "")
    end
  end
  end
"""
