defmodule Amphi.Posts do

  import Ecto.Query, warn: false
  alias Amphi.Repo
  alias Ecto.Changeset
  alias Amphi.Models.Post

  def list_posts(assocs \\ []) do
    query = from p in Post,
            left_join: l in assoc(p, :liked_by_users),
            group_by: p.id,
            select: %{p | likes: count(l)}

    query = case assocs do
      [] -> query
      assocs -> preload(query, ^assocs)
    end

    Repo.all(query)
  end

  def get_post!(id, assocs \\ []) do
    query = from p in Post,
            where: p.id == ^id,
            left_join: l in assoc(p, :liked_by_users),
            group_by: p.id,
            select: %{p | likes: count(l)}

    query = case assocs do
      [] -> query
      assocs -> preload(query, ^assocs)
    end

    Repo.one!(query)
  end

  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Changeset.put_assoc(:paper, attrs["paper"])
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def like_post(params) do
    post = get_post!(params["post_id"])
    IO.inspect(post.liked_by)
    if not params["user_id"] in post.liked_by do
      upd = %{likes: post.likes + 1, user_id: params["user_id"], liked_by: post.liked_by ++ [params["user_id"]]}
      update_post(post, upd)
    else
      upd = %{likes: post.likes - 1, user_id: params["user_id"], liked_by: Enum.reject(post.liked_by, &(&1 == params["user_id"]))}
      update_post(post, upd)
      {:already_liked, post}
    end

  end

end
