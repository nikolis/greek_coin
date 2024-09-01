defmodule GreekCoinWeb.ActionView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.ActionView

  def render("index.json", %{actions: actions}) do
    %{data: render_many(actions, ActionView, "action.json")}
  end

  def render("show.json", %{action: action}) do
    %{data: render_one(action, ActionView, "action.json")}
  end

  def render("action.json", %{action: action}) do
    %{id: action.id,
      title: action.title}
  end
end
