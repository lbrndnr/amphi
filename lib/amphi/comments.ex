defmodule Amphi.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query, only: [from: 2]
  alias Amphi.Repo

  alias Amphi.Models.Comment

  def list_comments(post, assocs \\ []) do
    query = from c in Comment, where: c.post_id == ^post.id
    comments = Repo.all(query)
    case assocs do
      [] -> comments
      assocs -> Enum.map(comments, fn c -> Repo.preload(c, assocs) end)
    end
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

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
