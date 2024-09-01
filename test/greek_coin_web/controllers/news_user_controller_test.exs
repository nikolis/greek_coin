defmodule GreekCoinWeb.NewsUserControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Newsletter
  alias GreekCoin.Newsletter.NewsUser

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

  def fixture(:news_user) do
    {:ok, news_user} = Newsletter.create_news_user(@create_attrs)
    news_user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all newsusers", %{conn: conn} do
      conn = get(conn, Routes.news_user_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create news_user" do
    test "renders news_user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.news_user_path(conn, :create), news_user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.news_user_path(conn, :show, id))

      assert %{
               "id" => id,
               "canceled" => true,
               "description" => "some description",
               "email" => "some email",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.news_user_path(conn, :create), news_user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update news_user" do
    setup [:create_news_user]

    test "renders news_user when data is valid", %{conn: conn, news_user: %NewsUser{id: id} = news_user} do
      conn = put(conn, Routes.news_user_path(conn, :update, news_user), news_user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.news_user_path(conn, :show, id))

      assert %{
               "id" => id,
               "canceled" => false,
               "description" => "some updated description",
               "email" => "some updated email",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, news_user: news_user} do
      conn = put(conn, Routes.news_user_path(conn, :update, news_user), news_user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete news_user" do
    setup [:create_news_user]

    test "deletes chosen news_user", %{conn: conn, news_user: news_user} do
      conn = delete(conn, Routes.news_user_path(conn, :delete, news_user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.news_user_path(conn, :show, news_user))
      end
    end
  end

  defp create_news_user(_) do
    news_user = fixture(:news_user)
    {:ok, news_user: news_user}
  end
"""
end
