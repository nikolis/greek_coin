"""
defmodule GreekCoinWeb.FallbackController do
  use GreekCoinWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(GreekCoinWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(GreekCoinWeb.ErrorView)
    |> render(:"404")
  end
  end
"""
