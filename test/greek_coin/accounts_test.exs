defmodule GreekCoin.AccountsTest do
  use GreekCoin.DataCase

  alias GreekCoin.Accounts
  alias GreekCoin.Accounts.Address

  describe "addresses" do


    @valid_attrs %{city: "some city", country: "some country", title: "some title", zip: "some zip"}
    @update_attrs %{city: "some updated city", country: "some updated country", title: "some updated title", zip: "some updated zip"}
    @invalid_attrs %{city: nil, country: nil, title: nil, zip: nil}

    def address_fixture(attrs \\ %{}) do
      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_address()

      address
    end

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Accounts.list_addresses() == [address]
    end

    test "register user only with apropriate credentials should create a user" do
      result = Accounts.register_user(%{credential: %{email: "nikolaos.galerak@gmail.com", password: "somepassword"}})
      assert {:ok, _ } = result
    end

    test "register user only with missing email in credentials should create a changeset response" do
      case Accounts.register_user(%{credential: %{ password: "somepassword"}}) do
         {:error, %Ecto.Changeset{} =changeset} ->
            assert changeset.valid? == false
         {:ok, _ } ->
            assert false
      end
    end

    test "register user only with empty email in credentials should create a changeset response" do
      case Accounts.register_user(%{credential: %{ email: "" ,password: "somepassword"}}) do
         {:error, %Ecto.Changeset{} =changeset} ->
            assert changeset.valid? == false
         {:ok, _ } ->
            assert false
      end
    end

    test "register user only with empty password in credentials should create a changeset response" do
      case Accounts.register_user(%{credential: %{ email: "nikolis124@gmail.com" ,password: ""}}) do
         {:error, %Ecto.Changeset{} =changeset} ->
            assert changeset.valid? == false
         {:ok, _ } ->
            assert false
      end
    end

    test "register user without password in credentials should create a changeset response" do
      case Accounts.register_user(%{credential: %{ email: "nikolis124@gmail.com"}}) do
         {:error, %Ecto.Changeset{} =changeset} ->
            assert changeset.valid? == false
         {:ok, _ } ->
            assert false
      end
    end


    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Accounts.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      assert {:ok, %Address{} = address} = Accounts.create_address(@valid_attrs)
      assert address.city == "some city"
      assert address.country == "some country"
      assert address.title == "some title"
      assert address.zip == "some zip"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      assert {:ok, %Address{} = address} = Accounts.update_address(address, @update_attrs)
      assert address.city == "some updated city"
      assert address.country == "some updated country"
      assert address.title == "some updated title"
      assert address.zip == "some updated zip"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_address(address, @invalid_attrs)
      assert address == Accounts.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Accounts.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Accounts.change_address(address)
    end
  end

  describe "login_attempts" do
    alias GreekCoin.Accounts.LoginAttempt

    @valid_attrs %{ip_address: "some ip_address", result: "some result"}
    @update_attrs %{ip_address: "some updated ip_address", result: "some updated result"}
    @invalid_attrs %{ip_address: nil, result: nil}

    def login_attempt_fixture(attrs \\ %{}) do
      {:ok, login_attempt} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_login_attempt()

      login_attempt
    end

    test "list_login_attempts/0 returns all login_attempts" do
      login_attempt = login_attempt_fixture()
      assert Accounts.list_login_attempts() == [login_attempt]
    end

    test "get_login_attempt!/1 returns the login_attempt with given id" do
      login_attempt = login_attempt_fixture()
      assert Accounts.get_login_attempt!(login_attempt.id) == login_attempt
    end

    test "create_login_attempt/1 with valid data creates a login_attempt" do
      assert {:ok, %LoginAttempt{} = login_attempt} = Accounts.create_login_attempt(@valid_attrs)
      assert login_attempt.ip_address == "some ip_address"
      assert login_attempt.result == "some result"
    end

    test "create_login_attempt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_login_attempt(@invalid_attrs)
    end

    test "update_login_attempt/2 with valid data updates the login_attempt" do
      login_attempt = login_attempt_fixture()
      assert {:ok, %LoginAttempt{} = login_attempt} = Accounts.update_login_attempt(login_attempt, @update_attrs)
      assert login_attempt.ip_address == "some updated ip_address"
      assert login_attempt.result == "some updated result"
    end

    test "update_login_attempt/2 with invalid data returns error changeset" do
      login_attempt = login_attempt_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_login_attempt(login_attempt, @invalid_attrs)
      assert login_attempt == Accounts.get_login_attempt!(login_attempt.id)
    end

    test "delete_login_attempt/1 deletes the login_attempt" do
      login_attempt = login_attempt_fixture()
      assert {:ok, %LoginAttempt{}} = Accounts.delete_login_attempt(login_attempt)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_login_attempt!(login_attempt.id) end
    end

    test "change_login_attempt/1 returns a login_attempt changeset" do
      login_attempt = login_attempt_fixture()
      assert %Ecto.Changeset{} = Accounts.change_login_attempt(login_attempt)
    end
  end
end
