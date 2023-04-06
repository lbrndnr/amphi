defmodule Amphi.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Amphi.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        likes: 42
      })
      |> Amphi.Posts.create_post()

    post
  end
end
