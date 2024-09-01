defmodule GreekCoinWeb.LoginAttemptControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Accounts
  alias GreekCoin.Accounts.LoginAttempt

  """

  @create_attrs %{
    ip_address: "some ip_address",
    result: "some result"
  }
  @update_attrs %{
    ip_address: "some updated ip_address",
    result: "some updated result"
  }
  @invalid_attrs %{ip_address: nil, result: nil}

  def fixture(:login_attempt) do
    {:ok, login_attempt} = Accounts.create_login_attempt(@create_attrs)
    login_attempt
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all login_attempts", %{conn: conn} do
      conn = get(conn, Routes.login_attempt_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create login_attempt" do
    test "renders login_attempt when data is valid", %{conn: conn} do
      conn = post(conn, Routes.login_attempt_path(conn, :create), login_attempt: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.login_attempt_path(conn, :show, id))

      assert %{
               "id" => id,
               "ip_address" => "some ip_address",
               "result" => "some result"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.login_attempt_path(conn, :create), login_attempt: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update login_attempt" do
    setup [:create_login_attempt]

    test "renders login_attempt when data is valid", %{conn: conn, login_attempt: %LoginAttempt{id: id} = login_attempt} do
      conn = put(conn, Routes.login_attempt_path(conn, :update, login_attempt), login_attempt: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.login_attempt_path(conn, :show, id))

      assert %{
               "id" => id,
               "ip_address" => "some updated ip_address",
               "result" => "some updated result"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, login_attempt: login_attempt} do
      conn = put(conn, Routes.login_attempt_path(conn, :update, login_attempt), login_attempt: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete login_attempt" do
    setup [:create_login_attempt]

    test "deletes chosen login_attempt", %{conn: conn, login_attempt: login_attempt} do
      conn = delete(conn, Routes.login_attempt_path(conn, :delete, login_attempt))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.login_attempt_path(conn, :show, login_attempt))
      end
    end
  end

  defp create_login_attempt(_) do
    login_attempt = fixture(:login_attempt)
    {:ok, login_attempt: login_attempt}
    end
"""
end
