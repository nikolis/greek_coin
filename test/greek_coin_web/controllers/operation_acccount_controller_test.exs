defmodule GreekCoinWeb.OperationAccountControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Accounting
  alias GreekCoin.Accounting.OperationAccount

"""
  @create_attrs %{
    description: "some description",
    src: "some src",
    title: "some title",
    url: "some url"
  }
  @update_attrs %{
    description: "some updated description",
    src: "some updated src",
    title: "some updated title",
    url: "some updated url"
  }
  @invalid_attrs %{description: nil, src: nil, title: nil, url: nil}

  def fixture(:operation_acccount) do
    {:ok, operation_acccount} = Accounting.create_operation_acccount(@create_attrs)
    operation_acccount
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all operation_accounts", %{conn: conn} do
      conn = get(conn, Routes.operation_acccount_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create operation_acccount" do
    test "renders operation_acccount when data is valid", %{conn: conn} do
      conn = post(conn, Routes.operation_acccount_path(conn, :create), operation_acccount: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.operation_acccount_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "src" => "some src",
               "title" => "some title",
               "url" => "some url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.operation_acccount_path(conn, :create), operation_acccount: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update operation_acccount" do
    setup [:create_operation_acccount]

    test "renders operation_acccount when data is valid", %{conn: conn, operation_acccount: %OperationAccount{id: id} = operation_acccount} do
      conn = put(conn, Routes.operation_acccount_path(conn, :update, operation_acccount), operation_acccount: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.operation_acccount_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "src" => "some updated src",
               "title" => "some updated title",
               "url" => "some updated url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, operation_acccount: operation_acccount} do
      conn = put(conn, Routes.operation_acccount_path(conn, :update, operation_acccount), operation_acccount: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete operation_acccount" do
    setup [:create_operation_acccount]

    test "deletes chosen operation_acccount", %{conn: conn, operation_acccount: operation_acccount} do
      conn = delete(conn, Routes.operation_acccount_path(conn, :delete, operation_acccount))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.operation_acccount_path(conn, :show, operation_acccount))
      end
    end
  end

  defp create_operation_acccount(_) do
    operation_acccount = fixture(:operation_acccount)
    {:ok, operation_acccount: operation_acccount}
  end
"""
end
