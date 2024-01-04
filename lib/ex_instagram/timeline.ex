defmodule ExInstagram.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias ExInstagram.Repo

  alias ExInstagram.Timeline.Post
  alias ExInstagram.Accounts.User

  def subscribe() do
    Phoenix.PubSub.subscribe(ExInstagram.PubSub, "posts")
  end

  defp broadcast({:error, _reason} = error, _), do: error

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(
      ExInstagram.PubSub,
      "posts",
      {event, post}
    )

    {:ok, post}
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  def list_posts_by_user(user) do
    Repo.all(from(p in Post, where: p.user_id == ^user.id, order_by: [desc: p.inserted_at]))
  end

  def list_posts_by_user(user, limit) do
    Repo.all(
      from(p in Post,
        where: p.user_id == ^user.id,
        order_by: [desc: p.inserted_at],
        limit: ^limit
      )
    )
    |> Repo.preload([:user])
  end

  def list_recent_posts(limit) do
    from(p in Post, order_by: [desc: p.inserted_at], limit: ^limit)
    |> Repo.all()
    |> Repo.preload([:user])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  # def create_post(attrs \\ %{}) do
  #   %Post{}
  #   |> Post.changeset(attrs)
  #   |> Repo.insert()
  #   |> broadcast(:post_created)
  # end

  def create_post(%User{} = user, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
    |> broadcast(:post_created)
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
