defmodule GreekCoinWeb.NewUserControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Newsletter
  alias GreekCoin.Newsletter.NewUser
"""
  @create_attrs %{
    canceled: true,
    description: "some description",
    email: "some email",
    status: "some status"
  }
  @update_attrs %{
    canceled: false,
    description: "some updated description",
    email: "some updated email",
    status: "some updated status"
  }
  @invalid_attrs %{canceled: nil, description: nil, email: nil, status: nil}

  def fixture(:new_user) do
    {:ok, new_user} = Newsletter.create_new_user(@create_attrs)
    new_user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all newsusers", %{conn: conn} do
      conn = get(conn, Routes.new_user_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create new_user" do
    test "renders new_user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.new_user_path(conn, :create), new_user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.new_user_path(conn, :show, id))

      assert %{
               "id" => id,
               "canceled" => true,
               "description" => "some description",
               "email" => "some email",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.new_user_path(conn, :create), new_user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update new_user" do
    setup [:create_new_user]

    test "renders new_user when data is valid", %{conn: conn, new_user: %NewUser{id: id} = new_user} do
      conn = put(conn, Routes.new_user_path(conn, :update, new_user), new_user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.new_user_path(conn, :show, id))

      assert %{
               "id" => id,
               "canceled" => false,
               "description" => "some updated description",
               "email" => "some updated email",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, new_user: new_user} do
      conn = put(conn, Routes.new_user_path(conn, :update, new_user), new_user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete new_user" do
    setup [:create_new_user]

    test "deletes chosen new_user", %{conn: conn, new_user: new_user} do
      conn = delete(conn, Routes.new_user_path(conn, :delete, new_user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.new_user_path(conn, :show, new_user))
      end
    end
  end

  defp create_new_user(_) do
    new_user = fixture(:new_user)
    {:ok, new_user: new_user}
  end
"""
end
