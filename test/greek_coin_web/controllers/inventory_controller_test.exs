defmodule GreekCoinWeb.InventoryControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Accounting
  alias GreekCoin.Accounting.Inventory
"""
  @create_attrs %{
    balance: 120.5
  }
  @update_attrs %{
    balance: 456.7
  }
  @invalid_attrs %{balance: nil}

  def fixture(:inventory) do
    {:ok, inventory} = Accounting.create_inventory(@create_attrs)
    inventory
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all inventories", %{conn: conn} do
      conn = get(conn, Routes.inventory_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create inventory" do
    test "renders inventory when data is valid", %{conn: conn} do
      conn = post(conn, Routes.inventory_path(conn, :create), inventory: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.inventory_path(conn, :show, id))

      assert %{
               "id" => id,
               "balance" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.inventory_path(conn, :create), inventory: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update inventory" do
    setup [:create_inventory]

    test "renders inventory when data is valid", %{conn: conn, inventory: %Inventory{id: id} = inventory} do
      conn = put(conn, Routes.inventory_path(conn, :update, inventory), inventory: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.inventory_path(conn, :show, id))

      assert %{
               "id" => id,
               "balance" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, inventory: inventory} do
      conn = put(conn, Routes.inventory_path(conn, :update, inventory), inventory: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete inventory" do
    setup [:create_inventory]

    test "deletes chosen inventory", %{conn: conn, inventory: inventory} do
      conn = delete(conn, Routes.inventory_path(conn, :delete, inventory))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.inventory_path(conn, :show, inventory))
      end
    end
  end

  defp create_inventory(_) do
    inventory = fixture(:inventory)
    {:ok, inventory: inventory}
  end
"""
end
