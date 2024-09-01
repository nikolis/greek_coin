defmodule GreekCoinWeb.ServingController do
  use GreekCoinWeb, :controller

  def main_page(conn, %{}) do
     render(conn, "index.html")
  end 

end
