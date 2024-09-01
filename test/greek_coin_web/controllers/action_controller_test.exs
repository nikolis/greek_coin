defmodule GreekCoinWeb.ActionControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Action

  @create_attrs %{
    title: "some title"
  }
  @update_attrs %{
    title: "some updated title"
  }
  @invalid_attrs %{title: nil}

  def fixture(:action) do
    {:ok, action} = Funds.create_action(@create_attrs)
    action
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all actions", %{conn: conn} do
      conn = get(conn, Routes.action_path(conn, :index))
      #assert json_response(conn, 200)["data"] == []
    end
  end


  defp create_action(_) do
    action = fixture(:action)
    {:ok, action: action}
  end
end
