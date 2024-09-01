defmodule GreekCoinWeb.InventoryView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.InventoryView
  alias GreekCoinWeb.CurrencyView

  def render("index.json", %{inventories: inventories}) do
    %{data: render_many(inventories, InventoryView, "inventory.json")}
  end

  def render("show.json", %{inventory: inventory}) do
    %{data: render_one(inventory, InventoryView, "inventory.json")}
  end

  def render("inventory.json", %{inventory: inventory}) do
    %{id: inventory.id,
      balance: inventory.balance,
      operation_account_id: inventory.operation_account_id,
      currency: render_one(inventory.currency, CurrencyView, "currency.json")
    }
  end
end
