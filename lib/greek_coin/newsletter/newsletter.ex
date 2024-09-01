defmodule GreekCoin.Newsletter do
  @moduledoc """
  The Newsletter context.
  """

  import Ecto.Query, warn: false
  alias GreekCoin.Repo

  alias GreekCoin.Newsletter.NewsUser

  @doc """
  Returns the list of newsusers.

  ## Examples

      iex> list_newsusers()
      [%NewUser{}, ...]

  """
  def list_newsusers do
    query = from news in NewsUser, where: news.status != "deleted"
    Repo.all(query)
  end

  alias GreekCoin.Newsletter.NewsUser

  @doc """
  Returns the list of newsusers.

  ## Examples

      iex> list_newsusers()
      [%NewsUser{}, ...]

  """
  def list_newsusers do
    Repo.all(NewsUser)
  end

  @doc """
  Gets a single news_user.

  Raises `Ecto.NoResultsError` if the News user does not exist.

  ## Examples

      iex> get_news_user!(123)
      %NewsUser{}

      iex> get_news_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_news_user!(id), do: Repo.get!(NewsUser, id)

  def get_news_user_by_email(email) do
     query = from nu in NewsUser,
      where: nu.email == ^email

     Repo.one query
  end

  @doc """
  Creates a news_user.

  ## Examples

      iex> create_news_user(%{field: value})
      {:ok, %NewsUser{}}

      iex> create_news_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_news_user(attrs \\ %{}) do
    %NewsUser{}
    |> NewsUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a news_user.

  ## Examples

      iex> update_news_user(news_user, %{field: new_value})
      {:ok, %NewsUser{}}

      iex> update_news_user(news_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_news_user(%NewsUser{} = news_user, attrs) do
    news_user
    |> NewsUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a NewsUser.

  ## Examples

      iex> delete_news_user(news_user)
      {:ok, %NewsUser{}}

      iex> delete_news_user(news_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_news_user(%NewsUser{} = news_user) do
    Repo.delete(news_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking news_user changes.

  ## Examples

      iex> change_news_user(news_user)
      %Ecto.Changeset{source: %NewsUser{}}

  """
  def change_news_user(%NewsUser{} = news_user) do
    NewsUser.changeset(news_user, %{})
  end
end
