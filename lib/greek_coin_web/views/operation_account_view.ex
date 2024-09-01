defmodule GreekCoinWeb.OperationAccountView do
  use GreekCoinWeb, :view
  alias GreekCoinWeb.OperationAccountView
  alias GreekCoinWeb.InventoryView

  def render("index.json", %{operation_accounts: operation_accounts}) do
    %{data: render_many(operation_accounts, OperationAccountView, "operation_account.json")}
  end

  def render("show.json", %{operation_account: operation_account}) do
    %{data: render_one(operation_account, OperationAccountView, "operation_account.json")}
  end

  def render("operation_account.json", %{operation_account: operation_account}) do
    %{id: operation_account.id,
      url: operation_account.url,
      title: operation_account.title,
      description: operation_account.description,
      src: operation_account.src,
      inventories: render_many(operation_account.inventories, InventoryView, "inventory.json") }
  end

  def render("operation_account_simple.json", %{operation_account: operation_account}) do
    %{id: operation_account.id,
      url: operation_account.url,
      title: operation_account.title,
      description: operation_account.description,
      src: operation_account.src,
      }
  end

end
