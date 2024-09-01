defmodule GreekCoinWeb.AddressController do
  use GreekCoinWeb, :controller

  alias GreekCoin.Accounts

  def index(conn, _params) do
    addresses = Accounts.list_addresses()
    render(conn, "index.html", addresses: addresses)
  end


  def show(conn, %{"id" => id}) do
    address = Accounts.get_address!(id)
    render(conn, "show.html", address: address)
  end

  def update(conn, %{"id" => id, "address" => address_params}) do
    address = Accounts.get_address!(id)

    case Accounts.update_address(address, address_params) do
      {:ok, address} ->
        conn
        |> json(address)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", address: address, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    address = Accounts.get_address!(id)
    {:ok, _address} = Accounts.delete_address(address)

    conn
    |> json("Deleted successfully")
  end
end
