defmodule GreekCoinWeb.TreasuryControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Funds
  alias GreekCoin.Funds.Treasury

"""
  @create_attrs %{
    balance: 120.5
  }
  @update_attrs %{
    balance: 456.7
  }
  @invalid_attrs %{balance: nil}

  def fixture(:treasury) do
    {:ok, treasury} = Funds.create_treasury(@create_attrs)
    treasury
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all trasuries", %{conn: conn} do
      conn = get(conn, Routes.treasury_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create treasury" do
    test "renders treasury when data is valid", %{conn: conn} do
      conn = post(conn, Routes.treasury_path(conn, :create), treasury: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.treasury_path(conn, :show, id))

      assert %{
               "id" => id,
               "balance" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.treasury_path(conn, :create), treasury: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update treasury" do
    setup [:create_treasury]

    test "renders treasury when data is valid", %{conn: conn, treasury: %Treasury{id: id} = treasury} do
      conn = put(conn, Routes.treasury_path(conn, :update, treasury), treasury: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.treasury_path(conn, :show, id))

      assert %{
               "id" => id,
               "balance" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, treasury: treasury} do
      conn = put(conn, Routes.treasury_path(conn, :update, treasury), treasury: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete treasury" do
    setup [:create_treasury]

    test "deletes chosen treasury", %{conn: conn, treasury: treasury} do
      conn = delete(conn, Routes.treasury_path(conn, :delete, treasury))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.treasury_path(conn, :show, treasury))
      end
    end
  end

  defp create_treasury(_) do
    treasury = fixture(:treasury)
    {:ok, treasury: treasury}
  end
"""
end
