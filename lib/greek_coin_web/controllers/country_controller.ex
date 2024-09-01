"""
defmodule GreekCoinWeb.CountryController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Localization
  alias GreekCoin.Localization.Country

  action_fallback GreekCoinWeb.FallbackController

  def index(conn, _params) do
    countries = Localization.list_countries()
    render(conn, "index.json", countries: countries)
  end

  def create(conn, %{"country" => country_params}) do
    with {:ok, %Country{} = country} <- Localization.create_country(country_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.country_path(conn, :show, country))
      |> render("show.json", country: country)
    end
  end

  def show(conn, %{"id" => id}) do
    country = Localization.get_country!(id)
    render(conn, "show.json", country: country)
  end

  def update(conn, %{"id" => id, "country" => country_params}) do
    country = Localization.get_country!(id)

    with {:ok, %Country{} = country} <- Localization.update_country(country, country_params) do
      render(conn, "show.json", country: country)
    end
  end

  def delete(conn, %{"id" => id}) do
    country = Localization.get_country!(id)

    with {:ok, %Country{}} <- Localization.delete_country(country) do
      send_resp(conn, :no_content, "")
    end
  end
  end
  """
