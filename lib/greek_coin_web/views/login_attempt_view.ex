defmodule GreekCoinWeb.LoginAttemptView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.LoginAttemptView
  import Kerosene.JSON

  def render("index.json", %{login_attempts: login_attempts}) do
    %{data: render_many(login_attempts, LoginAttemptView, "login_attempt.json")}
  end

  def render("list.json", %{login_attempts: login_attempts, kerosene: kerosene, conn: conn}) do
    %{data: render_many(login_attempts, LoginAttemptView, "login_attempt.json"),
      pagination: paginate(conn, kerosene)
    }
  end


  def render("show.json", %{login_attempt: login_attempt}) do
    %{data: render_one(login_attempt, LoginAttemptView, "login_attempt.json")}
  end

  def render("login_attempt.json", %{login_attempt: login_attempt}) do
    %{id: login_attempt.id,
      ip_address: login_attempt.ip_address,
      result: login_attempt.result,
      update_at: login_attempt.updated_at,
    }
  end
end
