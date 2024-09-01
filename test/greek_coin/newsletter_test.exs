defmodule GreekCoin.NewsletterTest do
  use GreekCoin.DataCase

  alias GreekCoin.Newsletter

  describe "newsusers" do
    alias GreekCoin.Newsletter.NewsUser

    @valid_attrs %{canceled: true, description: "some description", email: "some email", status: "some status"}
    @update_attrs %{canceled: false, description: "some updated description", email: "some updated email", status: "some updated status"}
    @invalid_attrs %{canceled: nil, description: nil, email: nil, status: nil}

    def news_user_fixture(attrs \\ %{}) do
      {:ok, news_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Newsletter.create_news_user()

      news_user
    end

    test "list_newsusers/0 returns all newsusers" do
      news_user = news_user_fixture()
      assert Newsletter.list_newsusers() == [news_user]
    end

    test "get_news_user!/1 returns the news_user with given id" do
      news_user = news_user_fixture()
      assert Newsletter.get_news_user!(news_user.id) == news_user
    end

    test "create_news_user/1 with valid data creates a news_user" do
      assert {:ok, %NewsUser{} = news_user} = Newsletter.create_news_user(@valid_attrs)
      assert news_user.canceled == true
      assert news_user.description == "some description"
      assert news_user.email == "some email"
      assert news_user.status == "some status"
    end

    test "create_news_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Newsletter.create_news_user(@invalid_attrs)
    end

    test "update_news_user/2 with valid data updates the news_user" do
      news_user = news_user_fixture()
      assert {:ok, %NewsUser{} = news_user} = Newsletter.update_news_user(news_user, @update_attrs)
      assert news_user.canceled == false
      assert news_user.description == "some updated description"
      assert news_user.email == "some updated email"
      assert news_user.status == "some updated status"
    end

    test "update_news_user/2 with invalid data returns error changeset" do
      news_user = news_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Newsletter.update_news_user(news_user, @invalid_attrs)
      assert news_user == Newsletter.get_news_user!(news_user.id)
    end

    test "delete_news_user/1 deletes the news_user" do
      news_user = news_user_fixture()
      assert {:ok, %NewsUser{}} = Newsletter.delete_news_user(news_user)
      assert_raise Ecto.NoResultsError, fn -> Newsletter.get_news_user!(news_user.id) end
    end

    test "change_news_user/1 returns a news_user changeset" do
      news_user = news_user_fixture()
      assert %Ecto.Changeset{} = Newsletter.change_news_user(news_user)
    end
  end

end
