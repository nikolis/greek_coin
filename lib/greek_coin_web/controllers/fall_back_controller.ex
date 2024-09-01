defmodule GreekCoinWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use GreekCoinWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity) 
    |> put_view(GreekCoinWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end


  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Login error"})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(GreekCoinWeb.ErrorView)
    |> render(:"404")
  end 
    
  def call(conn, {:error, changeset}) do
    conn
    |> put_status(:unprocessable_entity) 
    |> render(GreekCoin.ChangesetView, "error.json", changeset: changeset)
  end
end     
