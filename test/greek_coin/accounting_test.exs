defmodule GreekCoin.AccountingTest do
  use GreekCoin.DataCase

  alias GreekCoin.Accounting
  alias GreekCoin.Repo

  describe "operation_accounts" do
    alias GreekCoin.Accounting.OperationAccount

    @update_attrs %{description: "some updated description", src: "some updated src", title: "some updated title", url: "some updated url"}
    @invalid_attrs %{description: nil, src: nil, title: nil, url: nil}
    @valid_attrs %{description: "some description", src: "some src", title: "some title", url: "some url"}

    def operation_acccount_fixture(attrs \\ %{}) do
      {:ok, operation_acccount} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounting.create_operation_acccount()

      operation_account = Repo.preload(operation_acccount, :inventories)
      operation_account
    end

    @valid_attrs_currency %{description: "some description", title: "some title", url: "some url"}

    def currency_fixture(attrs \\ %{}) do
      {:ok, currency} =
        attrs
        |> Enum.into(@valid_attrs_currency)
        |> Funds.create_currency()

      currency
    end

    test "list_operation_accounts/0 returns all operation_accounts" do
      operation_acccount = operation_acccount_fixture()
      assert Accounting.list_operation_accounts() == [operation_acccount]
    end

    test "get_operation_acccount!/1 returns the operation_acccount with given id" do
      operation_acccount = operation_acccount_fixture()
      assert Accounting.get_operation_acccount!(operation_acccount.id) == operation_acccount
    end

    test "create_operation_acccount/1 with valid data creates a operation_acccount" do
      assert {:ok, %OperationAccount{} = operation_acccount} = Accounting.create_operation_acccount(@valid_attrs)
      assert operation_acccount.description == "some description"
      assert operation_acccount.src == "some src"
      assert operation_acccount.title == "some title"
      assert operation_acccount.url == "some url"
    end

    test "create_operation_acccount/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_operation_acccount(@invalid_attrs)
    end

    test "update_operation_acccount/2 with valid data updates the operation_acccount" do
      operation_acccount = operation_acccount_fixture()
      assert {:ok, %OperationAccount{} = operation_acccount} = Accounting.update_operation_acccount(operation_acccount, @update_attrs)
      assert operation_acccount.description == "some updated description"
      assert operation_acccount.src == "some updated src"
      assert operation_acccount.title == "some updated title"
      assert operation_acccount.url == "some updated url"
    end

    test "update_operation_acccount/2 with invalid data returns error changeset" do
      operation_acccount = operation_acccount_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_operation_acccount(operation_acccount, @invalid_attrs)
      assert operation_acccount == Accounting.get_operation_acccount!(operation_acccount.id)
    end

    test "delete_operation_acccount/1 deletes the operation_acccount" do
      operation_acccount = operation_acccount_fixture()
      assert {:ok, %OperationAccount{}} = Accounting.delete_operation_acccount(operation_acccount)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_operation_acccount!(operation_acccount.id) end
    end

    test "change_operation_acccount/1 returns a operation_acccount changeset" do
      operation_acccount = operation_acccount_fixture()
      assert %Ecto.Changeset{} = Accounting.change_operation_acccount(operation_acccount)
    end
  end

  describe "inventories" do
    alias GreekCoin.Accounting.Inventory
    alias GreekCoin.Funds

    @valid_attrs %{balance: 120.5}
    @update_attrs %{balance: 456.7}
    @invalid_attrs %{balance: nil}

    def inventory_fixture(attrs \\ %{}) do
      currency = currency_fixture_inv()
      account = operation_acccount_fixture_inv()
      attrs =
        %{ currency_id: currency.id, operation_account_id: account.id }
        |> Enum.into(@valid_attrs)

      {:ok, inventory} =
        attrs
        |> Accounting.create_inventory()

      Repo.preload(inventory, :currency)
    end

    @valid_attrs_operation_account %{description: "some description", src: "some src", title: "some title", url: "some url"}

    def operation_acccount_fixture_inv() do
      {:ok, operation_acccount} =
        
        @valid_attrs_operation_account
        |> Accounting.create_operation_acccount()

      operation_acccount
    end

    @valid_attrs_currency %{description: "some description", title: "some title", url: "some url"}

    def currency_fixture_inv() do
      {:ok, currency} =
        @valid_attrs_currency
        |> Funds.create_currency()

      currency
    end


    test "list_inventories/0 returns all inventories" do
      inventory = inventory_fixture()
      assert Accounting.list_inventories() == [inventory]
    end

    test "get_inventory!/1 returns the inventory with given id" do
      inventory = inventory_fixture()
      assert Accounting.get_inventory!(inventory.id) == inventory
    end

    test "create_inventory/1 with valid data creates a inventory" do
      currency = currency_fixture_inv()
      account = operation_acccount_fixture_inv()
      attrs =
        %{ currency_id: currency.id, operation_account_id: account.id }
        |> Enum.into(@valid_attrs)
      assert {:ok, %Inventory{} = inventory} = Accounting.create_inventory(attrs)
      assert inventory.balance == 120.5
    end

    test "create_inventory/1 there should not be created 2 inventories with same currency and account params" do
      currency = currency_fixture_inv()
      account = operation_acccount_fixture_inv()
      attrs =
        %{ currency_id: currency.id, operation_account_id: account.id }
        |> Enum.into(@valid_attrs)
      assert {:ok, %Inventory{} = inventory} = Accounting.create_inventory(attrs)
      assert inventory.balance == 120.5

      assert {:error, error} = Accounting.create_inventory(attrs)
    end

    test "create_inventory/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_inventory(@invalid_attrs)
    end

    test "update_inventory/2 with valid data updates the inventory" do
      inventory = inventory_fixture()
      assert {:ok, %Inventory{} = inventory} = Accounting.update_inventory(inventory, @update_attrs)
      assert inventory.balance == 456.7
    end

    test "update_inventory/2 with invalid data returns error changeset" do
      inventory = inventory_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_inventory(inventory, @invalid_attrs)
      assert inventory == Accounting.get_inventory!(inventory.id)
    end

    test "delete_inventory/1 deletes the inventory" do
      inventory = inventory_fixture()
      assert {:ok, %Inventory{}} = Accounting.delete_inventory(inventory)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_inventory!(inventory.id) end
    end

    test "change_inventory/1 returns a inventory changeset" do
      inventory = inventory_fixture()
      assert %Ecto.Changeset{} = Accounting.change_inventory(inventory)
    end
  end
end
