defmodule Amphi.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Amphi.Comments` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        likes: 42,
        text: "some text"
      })
      |> Amphi.Comments.create_comment()

    comment
  end
end
