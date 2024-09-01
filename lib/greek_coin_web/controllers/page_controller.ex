defmodule GreekCoinWeb.PageController do
  use GreekCoinWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
