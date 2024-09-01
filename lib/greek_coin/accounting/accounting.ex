defmodule GreekCoin.Accounting do
  @moduledoc """
  The Accounting context.
  """

  import Ecto.Query, warn: false
  alias GreekCoin.Repo

  alias GreekCoin.Accounting.OperationAccount

  @doc """
  Returns the list of operation_accounts.

  ## Examples

      iex> list_operation_accounts()
      [%OperationAcccount{}, ...]

  """
  def list_operation_accounts do
    Repo.all(OperationAccount)
    |> Repo.preload([{:inventories, [:currency]}])
  end

  @doc """
  Gets a single operation_acccount.

  Raises `Ecto.NoResultsError` if the Operation acccount does not exist.

  ## Examples

      iex> get_operation_acccount!(123)
      %OperationAcccount{}

      iex> get_operation_acccount!(456)
      ** (Ecto.NoResultsError)

  """
  def get_operation_acccount!(id) do
    Repo.get!(OperationAccount, id)
    |> Repo.preload([{:inventories, [:currency]}])
  end

  @doc """
  Creates a operation_acccount.

  ## Examples

      iex> create_operation_acccount(%{field: value})
      {:ok, %OperationAcccount{}}

      iex> create_operation_acccount(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_operation_acccount(attrs \\ %{}) do
    %OperationAccount{}
    |> OperationAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a operation_acccount.

  ## Examples

      iex> update_operation_acccount(operation_acccount, %{field: new_value})
      {:ok, %OperationAcccount{}}

      iex> update_operation_acccount(operation_acccount, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_operation_acccount(%OperationAccount{} = operation_acccount, attrs) do
    operation_acccount
    |> OperationAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a OperationAcccount.

  ## Examples

      iex> delete_operation_acccount(operation_acccount)
      {:ok, %OperationAcccount{}}

      iex> delete_operation_acccount(operation_acccount)
      {:error, %Ecto.Changeset{}}

  """
  def delete_operation_acccount(%OperationAccount{} = operation_acccount) do
    Repo.delete(operation_acccount)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking operation_acccount changes.

  ## Examples

      iex> change_operation_acccount(operation_acccount)
      %Ecto.Changeset{source: %OperationAcccount{}}

  """
  def change_operation_acccount(%OperationAccount{} = operation_acccount) do
    OperationAccount.changeset(operation_acccount, %{})
  end

  alias GreekCoin.Accounting.Inventory

  @doc """
  Returns the list of inventories.

  ## Examples

      iex> list_inventories()
      [%Inventory{}, ...]

  """
  def list_inventories do
    Repo.all(Inventory)
    |> Repo.preload(:currency)
  end

  @doc """
  Gets a single inventory.

  Raises `Ecto.NoResultsError` if the Inventory does not exist.

  ## Examples

      iex> get_inventory!(123)
      %Inventory{}

      iex> get_inventory!(456)
      ** (Ecto.NoResultsError)

  """
  def get_inventory!(id) do
    Repo.get!(Inventory, id)
    |> Repo.preload(:currency)
  end

  def get_inventory(account_id, currency_id) do
    query = 
      from inv in Inventory,
      where: inv.operation_account_id == ^account_id
      and inv.currency_id == ^ currency_id
    Repo.one(query)
    |> Repo.preload([:currency])
  end


  @doc """
  Creates a inventory.

  ## Examples

      iex> create_inventory(%{field: value})
      {:ok, %Inventory{}}

      iex> create_inventory(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_inventory(attrs \\ %{}) do
    %Inventory{}
    |> Inventory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a inventory.

  ## Examples

      iex> update_inventory(inventory, %{field: new_value})
      {:ok, %Inventory{}}

      iex> update_inventory(inventory, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_inventory(%Inventory{} = inventory, attrs) do
    inventory
    |> Inventory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Inventory.

  ## Examples

      iex> delete_inventory(inventory)
      {:ok, %Inventory{}}

      iex> delete_inventory(inventory)
      {:error, %Ecto.Changeset{}}

  """
  def delete_inventory(%Inventory{} = inventory) do
    Repo.delete(inventory)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking inventory changes.

  ## Examples

      iex> change_inventory(inventory)
      %Ecto.Changeset{source: %Inventory{}}

  """
  def change_inventory(%Inventory{} = inventory) do
    Inventory.changeset(inventory, %{})
  end
end
