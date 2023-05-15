defmodule Amphi.Comments do
  @moduledoc """
  The Comments context.
  """
  import Ecto.Query, warn: false
  alias Amphi.Repo
  alias Ecto.Changeset
  alias Amphi.Models.Post

  alias Amphi.Models.Comment

  def list_comments(post, assocs \\ []) do
    query = from c in Comment,
      where: c.post_id == ^post.id,
      left_join: l in assoc(c, :liked_by_users),
      group_by: c.id,
      select: %{c | likes: count(l)}

    query = case assocs do
      [] -> query
      assocs -> preload(query, ^assocs)
    end

    Repo.all(query)
  end

  def get_comment!(id, assocs \\ []) do
    query = from c in Comment,
      where: c.id == ^id,
      left_join: l in assoc(c, :liked_by_users),
      group_by: c.id,
      select: %{c | likes: count(l)}

    query = case assocs do
      [] -> query
      assocs -> preload(query, ^assocs)
    end

    Repo.one!(query)
  end

  def create_comment(attrs \\ %{}, assocs \\ []) do
    comment = %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

end
