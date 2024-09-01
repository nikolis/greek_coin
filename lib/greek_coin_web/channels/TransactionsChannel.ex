defmodule GreekCoinWeb.TransactionsChannel do
  use GreekCoinWeb, :channel

  def join("transactions:" <> transaction_id, _params, socket) do
    #{:ok, assign(socket, :transaction_id, String.to_integer(transaction_id))}
    :timer.send_interval(5_000, :ping)
    {:ok, socket}
  end

  def handle_broadcast() do
    GreekCoinWeb.Endpoint.broadcast_from!(self(), "transactions:1", "new_transaction")
  end

  def handle_info(:ping, socket) do
     count = socket.assigns[:count] || 1
     push(socket, "ping", %{count: count})
     {:noreply, assign(socket, :count, count + 1)}
  end 
end
